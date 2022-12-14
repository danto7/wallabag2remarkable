ID_REGEX = /__(\d+)$/

def run_wallabag_sync(wallabag, config)
  remarkable = Remarkable.new

  w_entries = wallabag.entries

  w_entries.reject! { |e| e["tags"].map { |t| t["label"] }.include?("video") }

  new_entries = w_entries.reject { |entry| config.entry_ids.include? entry["id"] }

  if new_entries.empty? && config.last_full_update.present? && config.last_full_update > 5.minutes.ago
    puts ">> no new entries. assuming nothing has updated"
  else
    puts ">> found new entries or last update is longer than 5 minutes ago"
    config.last_full_update = Time.now.utc

    puts ">> uploading new documents:"
    new_entries.each do |entry|
      id = entry["id"]
      filename = create_filename("#{entry["title"]}__#{id}.epub")
      puts "- #{filename}"
      File.write(filename, wallabag.export_entry(id))
      remarkable.upload_document(filename, "/wallabag")
      File.delete(filename)
      config.entry_ids << id
    end

    # archiving deleted entries
    r_entries = remarkable
      .list_files("/wallabag")
      .map { |name| {name: name, id: name.match(ID_REGEX)[1].to_i} }

    r_entries_ids = r_entries.map { |entry| entry[:id] }
    deleted_entries = config.entry_ids.reject { |id| r_entries_ids.include? id }

    puts ">> archiving deleted entries from wallabag"
    deleted_entries.each do |id|
      puts "- #{id}"
      wallabag.archive_entry(id)
      config.entry_ids.delete(id)
    end

    puts ">> deleting archived entries from remarkable"
    w_entries_ids = w_entries.map { |entry| entry["id"] }
    archived_entries_ids = config.entry_ids.difference(w_entries_ids)

    archived_files = r_entries
      .select { |entry| archived_entries_ids.include? entry[:id] }
      .map { |entry| entry[:name] }

    archived_files.each do |file|
      puts "- #{file}"
      remarkable.delete_document "/wallabag/#{file}"
    end
  end
end
