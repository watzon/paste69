class AppServer < Lucky::BaseAppServer
  # Learn about middleware with HTTP::Handlers:
  # https://luckyframework.org/guides/http-and-routing/http-handlers
  def middleware : Array(HTTP::Handler)
    swagger = LuckySwagger::Middleware.new

    [
      Lucky::RequestIdHandler.new,
      Lucky::ForceSSLHandler.new,
      Lucky::HttpMethodOverrideHandler.new,
      Lucky::LogHandler.new,
      Lucky::ErrorHandler.new(action: Errors::Show),
      Raven::Lucky::ErrorHandler.new,
      Lucky::RemoteIpHandler.new,
      Lucky::RouteHandler.new,
      Lucky::StaticCompressionHandler.new("./public", file_ext: "gz", content_encoding: "gzip"),
      Lucky::StaticFileHandler.new("./public", fallthrough: false, directory_listing: false),
      swagger.api_handler,
      swagger.web_handler,
      Lucky::RouteNotFoundHandler.new,
    ] of HTTP::Handler
  end

  def protocol
    "http"
  end

  def listen
    server.listen(host, port, reuse_port: false)
  end
end
