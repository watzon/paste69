module Paste69
  module ServiceIncluder
    protected def self.config
      ADI.container.config_manager
    end

    protected def config
      ADI.container.config_manager
    end

    protected def self.utils
      ADI.container.utils_service
    end

    protected def utils
      ADI.container.utils_service
    end

    protected def self.s3_client
      ADI.container.s3_client
    end

    protected def s3_client
      ADI.container.s3_client
    end

    protected def self.url_encoder
      ADI.container.url_encoder
    end

    protected def url_encoder
      ADI.container.url_encoder
    end

    protected def db_service
      ADI.container.db_service
    end

    protected def self.db_service
      ADI.container.db_service
    end
  end
end
