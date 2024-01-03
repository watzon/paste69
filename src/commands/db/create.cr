require "micrate"

module Paste69
  @[ACONA::AsCommand("db:create")]
  @[ADI::Register(public: true)]
  class Commands::DB::Create < ACON::Command
    def initialize(@config : Paste69::ConfigManager); end

    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      Micrate.connection_url = @config.get("database_url").as_s
      Micrate::Cli.create_database

      Status::SUCCESS
    end
  end
end
