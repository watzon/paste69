module Paste69
  @[ADI::Register(public: true, name: "s3_client")]
  class S3Client
    getter client : Awscr::S3::Client?

    def initialize(@config : Paste69::ConfigManager)
      if config.get("storage.type") == "s3"
        @client = Awscr::S3::Client.new(
          @config.get("storage.s3.region").as_s,
          @config.get("storage.s3.access_key").as_s,
          @config.get("storage.s3.secret_key").as_s
        )
      end
    end

    def put_object(*args, **kwargs)
      raise_if_not_configured
      @client.not_nil!.put_object(*args, **kwargs)
    end

    def get_object(*args, **kwargs)
      raise_if_not_configured
      @client.not_nil!.get_object(*args, **kwargs)
    end

    def delete_object(*args, **kwargs)
      raise_if_not_configured
      @client.not_nil!.delete_object(*args, **kwargs)
    end

    private def raise_if_not_configured
      raise "S3 storage is not configured" unless @client
    end
  end
end
