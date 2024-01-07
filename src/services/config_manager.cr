module Paste69
  @[ADI::Register(name: "config_manager", public: true)]
  class ConfigManager
    DEFAULTS = {
      "host" => "0.0.0.0",
      "port" => 8080,
      "site_url" => "0.0.0.0:8080",
      "use_ssl" => false,
      "database_url" => "sqlite://./db/data.db",
      "templates_dir" => "src/templates",
      "max_content_length" => 256 * 1024 * 1024,
      "max_url_length" => 4096,
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
        "text/plain" => ".txt",
        "text/x-diff" => ".diff",
      },
      "storage.mime_blocklist" => [
        "application/x-dosexec",
        "application/java-archive",
        "application/java-vm"
      ],
      "storage.upload_blocklist" => nil,
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

    getter config : Totem::Config
    getter upload_blocklist = [] of Subnet::IPv4 | Subnet::IPv6

    delegate :get, :set, to: @config

    def initialize
      config = @config = Totem.new("config", "/etc/paste69")
      config.config_paths << "./config"
      config.config_paths << "~/.paste69"
      config.config_paths << "~/.config/paste69"

      config.set_defaults(DEFAULTS)
      config.load! rescue nil
      config.automatic_env

      init_upload_blocklist
    end

    def init_upload_blocklist
      if path = get("storage.upload_blocklist").as_s?
        text = File.read(path)
        text = text.gsub(/#.*/, "").gsub(/\n+/, "\n")
        lines = text.lines.map(&.strip)
        lines.each_with_index do |line, i|
          begin
            ip = Subnet.parse(line)
            @upload_blocklist << ip
          rescue ex : ArgumentError
            # TODO: Use logger instead of puts.
            puts "Invalid IP address in upload blocklist line #{i + 1}"
          end
        end
      end
    end
  end
end
