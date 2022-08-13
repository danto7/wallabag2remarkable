class Remarkable
  def list_files(prefix = "/")
    `rmapi ls #{prefix}`
      .lines
      .map { |entry| entry.chomp.split("\t") }
      .select { |entry| entry.first == "[f]" }
      .map { |entry| entry[1] }
  end

  def upload_document(filename, location)
    `rmapi put "#{filename}" "#{location}"`
  end

  def delete_document(path)
    `rmapi rm "#{path}"`
  end
end
