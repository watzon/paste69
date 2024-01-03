require "digest/sha256"

module Paste69
  class Paste < Crecto::Model
    extend ServiceIncluder
    include ServiceIncluder

    unique_constraint :sha256

    schema "pastes" do
      field :id, Int64, primary_key: true
      field :sha256, String
      field :ext, String
      field :mime, String
      field :addr, String
      field :ua, String
      field :removed, Bool, default: false
      field :nsfw_score, Float64
      field :expiration, Int64
      field :mgmt_token, String
      field :secret, String
      field :last_vscan, Time
      field :size, Int64
    end

    def nsfw?
      threshold = config.get("nsfw.threshold").as_f
      (self.nsfw_score || 0.0) > threshold
    end

    def name
      "#{url_encoder.enbase(self.id.not_nil!)}#{self.ext}"
    end

    def url
      utils.url_for(self.name, secret: self.secret, anchor: self.nsfw? ? "nsfw" : nil) + "\n"
    end

    def path
      storage_type = config.get("storage.type").as_s
      if storage_type == "local"
        File.join(config.get("storage.path").as_s, self.sha256!)
      elsif storage_type == "s3"
        self.sha256!
      else
        raise "unknown storage type: #{storage_type}"
      end
    end

    def delete(permenant = false)
      storage_type = config.get("storage.type").as_s

      self.expiration = nil
      self.mgmt_token = nil
      self.removed = permenant
      db_service.update(self)

      if storage_type == "local"
        File.delete?(self.path)
      elsif storage_type == "s3"
        s3_client.delete_object(config.get("storage.s3.bucket").as_s, self.sha256!)
      else
        raise "unknown storage type: #{storage_type}"
      end
    end

    # requested_expiration can be:
    #   - `nil`, to use the longest allowed file lifespan
    #   - a duration (in hours) that the file should live for
    #   - a timestamp in epoch millis that the file should expire at
    #
    # Any value greater that the longest allowed file lifespan will be rounded down to that
    # value.
    def self.store(data, content_type : String? = nil, filename : String? = nil, requested_expiration : Int64? = nil, addr : String? = nil, ua : String? = nil, secret : Bool = false)
      digest = Digest::SHA256.hexdigest(data)

      expiration = utils.expiration_millis(data.size, requested_expiration)
      is_new = true
      is_updated = false

      if paste = db_service.get_by(Paste, sha256: digest)
        # If the file already exists
        if paste.removed
          # The file was removed by moderation, so don't accept it back
          raise Exceptions::UnavailableForLegalReasons.new("The file was removed by moderation")
        end

        if paste.expiration.nil?
          # The file has either expired or been deleted, so give it a new expiration date
          paste.expiration = expiration.to_i64

          # Also generate a new management token
          paste.mgmt_token = Random.new.urlsafe_base64(config.get("storage.secret_bytes").as_i)

          is_updated = true
        else
          # The file already exists, update the expiration as needed
          paste.expiration = [paste.expiration!, expiration].max.to_i64
          is_new = false
        end
      else
        mime = utils.get_mime(data, filename)
        ext = utils.get_ext(mime, filename)

        paste = Paste.new
        paste.sha256 = digest
        paste.ext = ext
        paste.mime = mime
        paste.expiration = expiration.to_i64
        paste.mgmt_token = Random.new.urlsafe_base64(config.get("storage.secret_bytes").as_i)
      end

      paste.addr = addr
      paste.ua = ua

      if is_new && secret
        paste.secret = Random.new.urlsafe_base64(config.get("storage.secret_bytes").as_i)
      end

      storage_type = config.get("storage.type").as_s
      if storage_type == "local"
        path = config.get("storage.path").as_s
        Dir.mkdir_p(path)
        path = path + "/" + digest

        if !File.exists?(path)
          File.open(path, "w") do |paste|
            paste.write(data)
          end
        end
      elsif storage_type == "s3"
        s3_client.put_object(config.get("storage.s3.bucket").as_s, digest, data)
      else
        raise "Unknown storage type: #{storage_type}"
      end

      paste.size = data.size

      if !paste.nsfw_score && config.get("nsfw.detect").as_bool
        # TODO: Kick-off the NSFW detection
      end

      if is_updated
        paste = db_service.update(paste)
      else
        paste = db_service.insert(paste)
      end

      { paste.not_nil!.instance, is_new }
    end

    def retrieve(&block)
      return nil if self.expiration.nil? || self.mgmt_token.nil?
      storage_type = config.get("storage.type").as_s
      if storage_type == "local"
        uploads_dir = config.get("storage.path").as_s
        yield File.join(uploads_dir, self.sha256!)
      elsif storage_type == "s3"
        begin
          resp = s3_client.get_object(config.get("storage.s3.bucket").as_s, self.sha256!)
          body = resp.body.to_slice
          tempfile = File.tempfile(self.sha256!, self.ext!) do |file|
            file.write(body)
          end
          yield tempfile.path
          tempfile.delete
        rescue ex
        end
      else
        raise "Unknown storage type: #{storage_type}"
      end
    end
  end
end
