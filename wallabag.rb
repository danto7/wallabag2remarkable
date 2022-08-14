class Wallabag
  attr_reader :conn, :config

  def initialize(config)
    @conn = Faraday.new(
      url: "https://wallabag.d-jensen.de",
      headers: {"Content-Type" => "application/json"}
    )
    @config = config
  end

  def authenticate!
    client_id = ENV.fetch("CLIENT_ID") { raise "no CLIENT_ID provided" }
    client_secret = ENV.fetch("CLIENT_SECRET") { raise " no CLIENT_SECRET provided" }

    res = if config.refresh_token?
      conn.post("/oauth/v2/token") do |req|
        req.body = {
          grant_type: "refresh_token",
          refresh_token: config.refresh_token,
          client_id: client_id,
          client_secret: client_secret
        }.to_json
      end
    else
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
    raise "authentication failed: #{res.body}" unless res.success?
    body = JSON.parse(res.body)
    config.refresh_token = body["refresh_token"]
    conn.headers["Authorization"] = "Bearer #{body["access_token"]}"
    ""
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
