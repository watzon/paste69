module Paste69
  @[ADI::Register(public: true, name: "url_encoder")]
  class UrlEncoder
    getter alphabet : String
    getter min_length : Int32

    def initialize(@config : Paste69::ConfigManager)
      @alphabet = @config.get("url_alphabet").as_s
      @min_length = 1
    end

    def enbase(x : Int) : String
      n = self.alphabet.size
      str = String.build do |str|
        while x > 0
          str << self.alphabet[x % n]
          x = x // n
        end
      end

      padding = self.alphabet[0].to_s * (self.min_length - str.size)
      str + padding
    end

    def debase(str : String) : Int64
      n = self.alphabet.size.to_i64
      res = 0_i64
      str.reverse.chars.each_with_index do |c, i|
        idx = self.alphabet.index!(c).to_i64
        res += idx * (n ** i)
      end
      res
    end
  end
end
