module Paste69
  @[ADI::Register(public: true)]
  class PasteController < ATH::Controller
    def initialize(@config : Paste69::ConfigManager, @utils : Paste69::UtilsService, @url_encoder : Paste69::UrlEncoder, @db : Paste69::DBService, @s3_client : Paste69::S3Client); end

    @[ARTA::Get("/{id}")]
    @[ARTA::Post("/{id}")]
    @[ARTA::Get("/{secret}/{id}")]
    @[ARTA::Post("/{secret}/{id}")]
    def get_paste(req : ATH::Request, id : String, secret : String? = nil) : ATH::Response
      path = id.split("/").first
      sufs = File.extname(path)
      name = File.basename(path, sufs)

      if name.includes?(".")
        raise ATH::Exceptions::NotFound.new("Not found")
      end

      id = @url_encoder.debase(name)

      if sufs.size > 0
        if (paste = @db.get(Paste, id)) && paste.ext == sufs
          if secret != paste.secret
            raise ATH::Exceptions::NotFound.new("Not found")
          end

          if paste.removed
            raise Exceptions::UnavailableForLegalReasons.new("Paste removed")
          end

          if req.method == "POST"
            fd = @utils.parse_formdata(req.request)

            if parts = fd["token"]?
              token = String.new(parts[1])
              raise ATH::Exceptions::BadRequest.new("Invalid token") unless token == paste.mgmt_token!
            else
              raise ATH::Exceptions::BadRequest.new("Missing token")
            end


            if fd.has_key?("delete")
              paste.delete
              return ATH::Response.new("", status: 200)
            elsif parts = fd["expires"]?
              _, expires = parts
              requested_expiration = String.new(expires).to_i64?
              raise ATH::Exceptions::BadRequest.new("Invalid expiration") unless requested_expiration
              paste.expiration = requested_expiration
              @db.update(paste)
              return ATH::Response.new("", status: 202)
            end

            raise ATH::Exceptions::NotFound.new("Not found")
          end

          if paste.expiration && paste.mgmt_token
            req.request.headers.delete("if-modified-since")
            storage_type = @config.get("storage.type").as_s
            if storage_type == "local"
              uploads_dir = @config.get("storage.path").as_s
              filepath = File.join(uploads_dir, paste.sha256!)
              return ATH::BinaryFileResponse.new(
                filepath,
                auto_last_modified: false,
                headers: HTTP::Headers{
                  "Content-Type" => paste.mime!.to_s,
                  "X-Expires" => paste.expiration!.to_s
              })
            elsif storage_type == "s3"
              begin
                resp = @s3_client.get_object(@config.get("storage.s3.bucket").as_s, paste.sha256!)
                body = resp.body.to_slice
                tempfile = File.tempfile(paste.sha256!, paste.ext!) do |file|
                  file.write(body)
                end
                return ATH::BinaryFileResponse.new(
                  tempfile.path,
                  auto_last_modified: false,
                  headers: HTTP::Headers{
                    "Content-Type" => paste.mime!.to_s,
                    "X-Expires" => paste.expiration!.to_s
                  }
                ).tap do |res|
                  res.delete_file_after_send = true
                end
              rescue ex
                puts "Error getting object: #{ex.message}"
              end
            else
              raise "Unknown storage type: #{storage_type}"
            end
          end
        end

        raise ATH::Exceptions::NotFound.new("Not found")
      else
        if req.method == "POST"
          raise ATH::Exceptions::MethodNotAllowed.new(["GET"], "Method not allowed")
        end

        if path.includes?("/")
          raise ATH::Exceptions::NotFound.new("Not found")
        end

        if u = @db.get(URL, id)
          spawn do
            u.hits = u.hits! + 1
            @db.update(u)
          end
          return ATH::RedirectResponse.new(u.url!, :permanent_redirect)
        end
      end

      raise ATH::Exceptions::NotFound.new("Not found")
    end

    @[ARTA::Post("/")]
    def create_paste(req : ATH::Request) : ATH::Response
      form = @utils.parse_formdata(req.request)

      _, secret = form["secret"]? || {nil, nil}
      _, expires = form["expires"]? || {nil, nil}

      content_type = req.headers["Content-Type"]?
      user_agent = req.headers["User-Agent"]?
      remote_addr = req.headers["Remote-Addr"]?

      if !remote_addr
        addr = req.request.remote_address
        if addr.is_a?(Socket::IPAddress)
          remote_addr = addr.address
        elsif addr.is_a?(Socket::UNIXAddress)
          remote_addr = addr.path
        end
      end

      if form.has_key?("file")
        filename, body = form["file"]
        @utils.store_file(
          body,
          content_type,
          filename,
          expires ? String.new(expires).to_i64 : nil,
          remote_addr,
          user_agent,
          !!secret,
        )
      elsif form.has_key?("url")
        _, body = form["url"]
        @utils.store_url(
          String.new(body),
          remote_addr,
          user_agent,
          !!secret,
        )
      elsif form.has_key?("shorten")
        _, body = form["shorten"]
        @utils.shorten(String.new(body))
      else
        raise ATH::Exceptions::BadRequest.new("Bad request")
      end
    end
  end
end
