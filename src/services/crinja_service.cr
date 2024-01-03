module Paste69
  @[ADI::Register(public: true, name: "crinja_service")]
  class CrinjaService
    getter renderer : Crinja

    delegate :get_template, to: @renderer

    def initialize(@config : Paste69::ConfigManager)
      templates_dir = @config.get("templates_dir").as_s
      renderer = @renderer = Crinja.new
      renderer.loader = Crinja::Loader::FileSystemLoader.new(templates_dir)
    end
  end
end
