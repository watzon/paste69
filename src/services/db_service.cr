module Paste69
  @[ADI::Register(public: true, name: "db_service")]
  class DBService
    include Crecto::Repo

    alias Query = Crecto::Repo::Query

    @@config = Crecto::Repo::Config.new

    def initialize(@cfg : Paste69::ConfigManager)
      db_uri = @cfg.get("database_url").as_s

      config do |conf|
        conf.adapter = case db_uri
          when /^postgres/
            Crecto::Adapters::Postgres
          when /^sqlite/
            Crecto::Adapters::SQLite3
          else
            raise "Unknown or unsupported database adapter: #{db_uri}"
          end
        conf.uri = db_uri
      end

      # TODO: Add debug flag to config
      # Crecto::DbLogger.set_handler(STDOUT)
    end

    def query
      Query.new
    end

    # Clean up expired files
    #
    # Deletes any files from the filesystem which have hit their expiration time.  This
    # doesn't remove them from the database, only from the filesystem.  It's recommended
    # that server owners run this command regularly, or set it up on a timer.
    def prune
      current_time = Time.utc.to_unix_ms

      expired_files_query = Query.where("expiration IS NOT NULL")
        .and(
          Query.where("expiration < ?", [current_time]))

      cleaned = 0
      expired_files = self.all(Paste, expired_files_query)

      expired_files.each do |file|
        file.delete
        cleaned += 1
      end

      puts "Pruned #{cleaned} expired files"
    end
  end
end
