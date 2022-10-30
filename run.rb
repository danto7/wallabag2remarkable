require "bundler/setup"

require_relative "./config"
require_relative "./utils"
require_relative "./wallabag"
require_relative "./remarkable"
require_relative "./ytdlp"
require_relative "./run_wallabag_sync"
require_relative "./run_ytdlp_download"

Faraday.default_adapter = :net_http

ID_REGEX = /__(\d+)$/

config = Config.load(ENV.fetch("CONFIG_FILE", "config.json"))
wallabag = Wallabag.new(config)
begin
  wallabag.authenticate!
rescue RuntimeError => e
  raise e if e.message != "authentication failed"
  puts ">> refresh_token expired. clearing refresh_token"
  config.refresh_token = nil
  wallabag.authenticate!
end

puts "--> Start wallabag sync"
run_wallabag_sync(wallabag, config)

puts "--> Start yt-dlp"
run_ytdlp_download(wallabag)

config.save!
