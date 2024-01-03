module Paste69
  @[ADI::Register(alias: ATH::ErrorRendererInterface, public: true)]
  struct ErrorHandler
    include Athena::Framework::ErrorRendererInterface

    def initialize(
      @request_store : ATH::RequestStore,
      @config : Paste69::ConfigManager,
      @crinja : Paste69::CrinjaService,
    ); end

    # :inherit:
    def render(exception : ::Exception) : ATH::Response
      if exception.is_a? ATH::Exceptions::HTTPException
        status = exception.status
        headers = exception.headers
      else
        status = HTTP::Status::INTERNAL_SERVER_ERROR
        headers = HTTP::Headers.new
      end

      template = "#{status.to_i}.html.j2"
      templates = @crinja.renderer.loader.list_templates
      if !templates.includes?(template)
        template = "500.html.j2"
      end

      body = @crinja.get_template(template)
        .render({
          path: @request_store.request.path,
          headers: headers.to_h,
          config: @config.config.to_h,
        })

      headers["content-type"] = "text/html"

      ATH::Response.new body, status, headers
    end
  end
end
