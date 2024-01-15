module Paste69
  @[ADI::Register(public: true, name: "utils_service")]
  class UtilsService
    def initialize(@config : Paste69::ConfigManager, @type_checker : Paste69::TypeChecker); end

    def url_for(name, *, secret : String? = nil, anchor : String? = nil)
      url = @config.get("site_url").as_s
      ssl = @config.get("use_ssl").as_bool

      url = secret ? File.join(url, secret, name) : File.join(url, name)
      url += "##{anchor}" if anchor

      scheme = ssl ? "https" : "http"
      url = "#{scheme}://#{url}"
      url.strip("/")
    end

    def is_fhost_url?(url : String)
      uri = URI.parse(url)
      return uri.host == @config.get("host").as_s
    end

    URL_REGEX = /^(?:https?:\/\/)([\w\.-]+)(?:\/.*)?$/

    def url_valid?(url : String)
      match = url =~ URL_REGEX
      match != nil
    end

    # For a file of a given size, determine the largest allowed lifespan of that file
    #
    # Based on the current app's configuration:  Specifically, the MAX_CONTENT_LENGTH, as well
    # as STORAGE.{MIN,MAX}_EXPIRATION.
    #
    # This lifespan may be shortened by a user's request, but no files should be allowed to
    # expire at a point after this number.
    #
    # Value returned is a duration in milliseconds.
    def max_lifespan(size : Int32)
      min_exp = @config.get("storage.min_expiration").as_i64
      max_exp = @config.get("storage.max_expiration").as_i64
      max_size = @config.get("max_content_length").as_i64
      # min_exp + int((-max_exp + min_exp) * (filesize / max_size - 1) ** 3)
      min_exp + ((-max_exp - min_exp) * (size.to_f / max_size - 1) ** 3).to_i64
    end

    def shorten(url : String)
      url = url.strip

      if url.size > @config.get("max_url_length").as_i
        raise Exceptions::URITooLong.new(url)
      end

      if !url_valid?(url) || is_fhost_url?(url)
        raise ATH::Exceptions::BadRequest.new("Invalid URL")
      end

      u = URL.get(url)
      ATH::Response.new(u.get_url)
    end

    def in_upload_blocklist?(addr : String)
      ip = Subnet.parse(addr)
      bl = @config.upload_blocklist
      bl.any? { |b| b.includes?(ip) }
    end

    def store_file(data, content_type : String? = nil, filename : String? = nil, requested_expiration : Int64? = nil, addr : String? = nil, ua : String? = nil, secret : Bool = false)
      if addr && in_upload_blocklist?(addr)
        raise Exceptions::UnavailableForLegalReasons.new("Your host is blocked from uploading files")
      end

      sf, is_new = Paste.store(data, content_type, filename, requested_expiration, addr, ua, secret)

      res = ATH::Response.new(sf.url, headers: HTTP::Headers{ "X-Expires" => sf.expiration!.to_s })

      if is_new
        res.headers["X-Token"] = sf.mgmt_token!
      end

      res
    end

    def store_url(url : String, filename : String? = nil, requested_expiration : Int64? = nil, addr : String? = nil, ua : String? = nil, secret : Bool = false)
      if is_fhost_url?(url)
        raise ATH::Exceptions::BadRequest.new("Invalid URL")
      end

      headers = HTTP::Headers{  "Accept-Encoding" => "identity" }
      res = HTTP::Client.get(url, headers: headers)
      attempts = 1

      while (location = res.headers["Location"]?) && attempts <= 3
        res = HTTP::Client.get(location, headers: headers)
        attempts += 1
      end

      if res.status.to_i >= 300
        raise ATH::Exceptions::BadRequest.new("URL response was not OK")
      end

      if res.headers.has_key?("Content-Length")
        l = res.headers["Content-Length"].to_i64
        if l <= @config.get("max_content_length").as_i64
          filename ||= File.basename(url)
          return store_file(res.body.to_slice, res.headers["Content-Type"], filename, nil, addr, ua, secret)
        else
          raise Exceptions::ContentTooLarge.new("Content-Length was too large")
        end
      else
        raise Exceptions::LengthRequired.new("Content-Length was not provided")
      end
    end

    def parse_formdata(request : HTTP::Request) : Hash(String, Tuple(String?, Bytes))
      form = {} of String => Tuple(String?, Bytes)
      HTTP::FormData.parse(request) do |fd|
        form[fd.name] = {fd.filename, fd.body.getb_to_end}
      end
      form
    end

    def get_ext(mime : String, filename : String? = nil)
      if filename
        ext = File.extname(filename)
        max_len = @config.get("max_ext_length").as_i
        if ext.size > max_len
          ext = ext[0..max_len]
        end
      end

      gmime = mime.split(";")[0]
      guess = MIME.extensions(gmime).first?

      if !ext || ext.empty?
        override = @config.get("storage.ext_override").as_h
        if gmime.in?(override)
          ext = override[gmime].as_s
        elsif guess && !guess.empty?
          ext = guess
        else
          ext = ".bin"
        end
      end

      ext
    end

    def get_mime(buffer : Bytes, filename : String? = nil)
      if filename
        guess = MIME.from_filename?(filename)
      end

      # Detect the mimetype of the body
      if !guess
        # We need to do a little extra work to detect the mimetype
        body_io = IO::Memory.new(buffer)
        guess = @type_checker.of?(body_io)
      end

      mime = guess || "text/plain"

      # Check the mimetype against the blocklist
      if @config.get("storage.mime_blocklist").as_a.includes?(mime)
        raise ATH::Exceptions::UnsupportedMediaType.new("Blacklisted filetype")
      end

      if mime.size > 128
        raise ATH::Exceptions::BadRequest.new("Mimetype too long")
      end

      if mime.starts_with?("text/") && !mime.includes?("charset")
        mime += "; charset=utf-8"
      end

      mime
    end

    # Returns the epoch millisecond that a file should expire
    #
    # Uses the expiration time provided by the user (requested_expiration)
    # upper-bounded by an algorithm that computes the size based on the size of the
    # file.
    #
    # That is, all files are assigned a computed expiration, which can voluntarily
    # shortened by the user either by providing a timestamp in epoch millis or a
    # duration in hours.
    def expiration_millis(size : Int32, requested_expiration : Int64? = nil)
      current_epoch_millis = Time.utc.to_unix_ms

      # Maximum lifetime of the file in milliseconds
      files_max_lifespan = max_lifespan(size)

      # The latest allowed expiration date for this file, in epoch millis
      files_max_expiration = files_max_lifespan + current_epoch_millis

      if requested_expiration.nil?
        files_max_expiration
      elsif requested_expiration < 1_650_460_320_000
        # Treat the requested expiration time as a duration in hours
        requested_expiration_ms = requested_expiration * 60 * 60 * 1000
        [requested_expiration_ms, files_max_expiration].min
      else
        # Treat the requested expiration time as a timestamp in epoch millis
        [requested_expiration, files_max_expiration].min
      end
    end
  end
end
