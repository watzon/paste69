module Paste69
  @[ADI::Register(public: true, name: "type_checker")]
  class TypeChecker
    getter type_checker : Magic::TypeChecker

    delegate :of?, to: @type_checker

    def initialize
      @type_checker = Magic.mime_type
    end
  end
end
