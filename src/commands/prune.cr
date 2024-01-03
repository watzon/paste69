module Paste69
  @[ACONA::AsCommand("prune", description: "Clean up expired files.")]
  @[ADI::Register(public: true)]
  class Commands::Prune < ACON::Command
    def initialize(@db : Paste69::DBService); end

    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      @db.prune

      Status::SUCCESS
    end
  end
end
