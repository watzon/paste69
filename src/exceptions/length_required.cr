module Paste69
  module Exceptions
    class LengthRequired < Athena::Framework::Exceptions::HTTPException
      def initialize(message : String, cause : Exception | Nil = nil, headers : HTTP::Headers = HTTP::Headers.new)
        super(:length_required, message, cause, headers)
      end
    end
  end
end
