module Paste69
  module Exceptions
    class ContentTooLarge < Athena::Framework::Exceptions::HTTPException
      def initialize(message : String, cause : Exception | Nil = nil, headers : HTTP::Headers = HTTP::Headers.new)
        super(:payload_too_large, message, cause, headers)
      end
    end
  end
end
