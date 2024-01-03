require "./main"

ATH.run(
  port: ADI.container.config_manager.get("port").as_i,
  host: ADI.container.config_manager.get("host").as_s,
)
