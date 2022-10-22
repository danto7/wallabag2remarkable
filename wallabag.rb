require "active_support"
require "active_support/core_ext"
require "faraday"
require "faraday/net_http"

class Wallabag
  attr_reader :conn, :config

  def initialize(config)
    @config = config
    site_url = ENV.fetch("WALLABAG_URL") { raise "no WALLABAG_URL provided" }
    @conn = Faraday.new(
      url: site_url,
      headers: {"Content-Type" => "application/json"}
    )
  end

  def authenticate!
    conn.headers["Authorization"] = "Bearer #{access_token}"
    true
  end

  def access_token
    puts "use existing access token" if config.access_token_valid?
    return config.access_token if config.access_token_valid?

    client_id = ENV.fetch("CLIENT_ID") { raise "no CLIENT_ID provided" }
    client_secret = ENV.fetch("CLIENT_SECRET") { raise " no CLIENT_SECRET provided" }

    response = if config.refresh_token?
      puts "refresh token"
      conn.post("/oauth/v2/token") do |req|
        req.body = {
          grant_type: "refresh_token",
          refresh_token: config.refresh_token,
          client_id: client_id,
          client_secret: client_secret
        }.to_json
      end
    else
      puts "new access token"
      conn.post("/oauth/v2/token") do |req|
        req.body = {
          grant_type: "password",
          client_id: client_id,
          client_secret: client_secret,
          username: ENV.fetch("USERNAME") { raise "no USERNAME provided" },
          password: ENV.fetch("PASSWORD") { raise "no PASSWORD provided" }
        }.to_json
      end
    end

    raise "authentication failed: #{res.body}" unless response.success?

    body = JSON.parse(response.body)
    config.refresh_token = body["refresh_token"]
    config.access_token_timeout = body["expires_in"].seconds.from_now.utc
    config.access_token = body["access_token"]
  end

  def entries
    res = conn.get("/api/entries.json") do |req|
      req.params["archive"] = 0
      req.params["perPage"] = 100
    end
    raise "fetch entries failed" unless res.success?
    JSON.parse(res.body)["_embedded"]["items"]
  end

  def export_entry(id)
    res = conn.get("/api/entries/#{id}/export.epub")
    raise "could not download entry id #{id}" unless res.success?
    res.body
  end

  def archive_entry(id)
    res = conn.patch("/api/entries/#{id}.json") do |req|
      req.body = {
        archive: 1
      }.to_json
    end
    raise "could not archive #{id}" unless res.success?
    res.body
  end

  def unarchive_entry(id)
    res = conn.patch("/api/entries/#{id}.json") do |req|
      req.body = {
        archive: 0
      }.to_json
    end
    raise "could not unarchive #{id}" unless res.success?
    res.body
  end
end
