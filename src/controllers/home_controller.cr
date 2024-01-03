module Paste69
  @[ADI::Register(public: true)]
  class HomeController < ATH::Controller
    def initialize(@config : Paste69::ConfigManager, @utils : Paste69::UtilsService, @crinja : Paste69::CrinjaService); end

    @[ARTA::Get("/")]
    def index : ATH::Response
      template = @crinja.get_template("index.html.j2")
      rendered = template.render({
        fhost_url: @utils.url_for("/"),
        config: @config.config.to_h,
      })
      ATH::Response.new(rendered, 200, HTTP::Headers{"Content-Type" => "text/html"})
    end
  end
end
