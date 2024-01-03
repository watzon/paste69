require "./main"

# Prune the database every day at 00:00:00
Tasker.cron("0 0 0 * * *") do
  ADI.container.db_service.prune
end

ATH.run(
  port: ADI.container.config_manager.get("port").as_i,
  host: ADI.container.config_manager.get("host").as_s,
)
