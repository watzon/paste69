module Paste69
  module Exceptions
    class UnavailableForLegalReasons < Athena::Framework::Exceptions::HTTPException
      def initialize(message : String, cause : Exception | Nil = nil, headers : HTTP::Headers = HTTP::Headers.new)
        super(:unavailable_for_legal_reasons, message, cause, headers)
      end
    end
  end
end
