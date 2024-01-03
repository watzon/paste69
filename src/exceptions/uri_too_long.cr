module Paste69
  module Exceptions
    class URITooLong < Athena::Framework::Exceptions::HTTPException
      def initialize(message : String, cause : Exception | Nil = nil, headers : HTTP::Headers = HTTP::Headers.new)
        super(:uri_too_long, message, cause, headers)
      end
    end
  end
end
