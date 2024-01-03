module Paste69
  @[ADI::Register(public: true, name: "db_service")]
  class DBService
    include Crecto::Repo

    @@config = Crecto::Repo::Config.new

    def initialize(@cfg : Paste69::ConfigManager)
      config do |conf|
        conf.adapter = Crecto::Adapters::Postgres
        conf.uri = @cfg.get("database_url").as_s
      end

      Crecto::DbLogger.set_handler(STDOUT)
    end
  end
end
