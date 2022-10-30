def run_ytdlp_download(wallabag)
  out_dir = ENV.fetch("YT_DOWNLOAD_DIR") { raise "no YT_DOWNLOAD_DIR set" }
  yt = Ytdlp.new
  video_entries = wallabag.entries(video_tag: true)
  video_entries = video_entries.take(1) if dry_run?
  puts "Found #{video_entries.size} entries"

  video_entries.each do |entry|
    puts "> start video download: #{entry["title"]}"
    url = entry["origin_url"] || entry["given_url"]

    yt.download(url, out_dir + "/")
    wallabag.archive_entry entry["id"] unless dry_run?
  end
end
