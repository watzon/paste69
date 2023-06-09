# Load .env file before any other config or app code
require "lucky_env"
LuckyEnv.load?(".env")

# Require your shards here
require "lucky"
require "avram/lucky"
require "carbon"
require "hashids"
require "lucky_swagger"
require "luce"
require "sanitize"

require "raven"
require "raven/integrations/lucky"
