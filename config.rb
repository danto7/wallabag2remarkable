Config = Struct.new(:filename, :refresh_token, :entry_ids, keyword_init: true) do
  def refresh_token?
    !refresh_token.nil? && !refresh_token.empty?
  end

  def save!
    config = to_h
    config.delete(:filename)
    File.write(filename, config.to_json)
    ""
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
