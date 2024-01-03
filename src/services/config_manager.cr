module Paste69
  @[ADI::Register(name: "config_manager", public: true)]
  class ConfigManager
    getter config : Totem::Config

    DEFAULTS = {
      "host" => nil,
      "port" => 8080,
      "database_url" => "sqlite://./db/data.db",
      "templates_dir" => "src/templates",
      "max_content_length" => 256 * 1024 * 1024,
      "max_url_length" => 4096,
      "use_x_sendfile" => false,
      "max_ext_length" => 9,
      "storage.path" => "./uploads",
      "storage.type" => "local",
      "storage.max_expiration" => 365_i64 * 24 * 60 * 60 * 1000,
      "storage.min_expiration" => 30_i64  * 24 * 60 * 60 * 1000,
      "storage.s3.region" => nil,
      "storage.s3.bucket" => nil,
      "storage.s3.access_key" => nil,
      "storage.s3.secret_key" => nil,
      "storage.secret_bytes" => 16,
      "storage.ext_override" => {
        "audio/flac" => ".flac",
        "image/gif" => ".gif",
        "image/jpeg" => ".jpg",
        "image/png" => ".png",
        "image/svg+xml" => ".svg",
        "video/webm" => ".webm",
        "video/x-matroska" => ".mkv",
        "application/octet-stream" => ".bin",
        "text/plain" => ".log",
        "text/plain" => ".txt",
        "text/x-diff" => ".diff",
      },
      "storage.mime_blacklist" => [
        "application/x-dosexec",
        "application/java-archive",
        "application/java-vm"
      ],
      "storage.upload_blacklist" => [] of String,
      "nsfw.detect" => false,
      "nsfw.threshold" => 0.608,
      "vscan.socket" => nil,
      "vscan.quarantine_path" => "./quarantine",
      "vscan.interval" => 7.days.to_i,
      "vscan.ignore" => [
        "Eicar-Test-Signature",
        "PUA.Win.Packer.XmMusicFile",
      ],
      "url_alphabet" => "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    }

    delegate :get, :set, to: @config

    def initialize
      config = @config = Totem.new("config", "/etc/paste69")
      config.config_paths << "~/.totem"
      config.config_paths << "~/.config/totem"
      config.config_paths << "./config"
      begin
        config.load!
        config.set_defaults(DEFAULTS)
      rescue ex
        puts "Fatal error loading config file: #{ex.message}"
        exit(1)
      end
    end
  end
end
