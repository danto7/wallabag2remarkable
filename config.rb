Config = Struct.new(:filename, :refresh_token, :access_token, :access_token_timeout, :entry_ids, keyword_init: true) do
  def refresh_token?
    refresh_token.present?
  end

  def save!
    config = to_h
    config.delete(:filename)
    File.write(filename, config.to_json)
  end

  def access_token_valid?
    return false if access_token.blank? || access_token_timeout.blank?

    Time.now + 3.minute < Date.parse(access_token_timeout)
  end
end

def Config.load(filename)
  config = if File.exist?(filename)
    json = JSON.parse(File.read(filename))
    Config.new(json)
  else
    Config.new
  end
  config.filename = filename
  config.entry_ids ||= []
  config
end
