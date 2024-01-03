module Paste69
  class URL < Crecto::Model
    extend ServiceIncluder
    include ServiceIncluder

    schema "urls" do
      field :id, Int64, primary_key: true
      field :url, String
      field :hits, Int64, default: 0
    end

    def name
      url_encoder.enbase(self.id.not_nil!)
    end

    def get_url
      utils.url_for(name) + "\n"
    end

    def self.get(url : String)
      if u = db_service.get_by(URL, url: url)
        u
      else
        u = URL.new
        u.url = url
        u = db_service.insert(u)
        u.instance
      end
    end
  end
end
