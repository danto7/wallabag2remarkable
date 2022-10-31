SPONSORBLOCK = "--sponsorblock-remove sponsor --sponsorblock-mark default"

class Ytdlp
  def download(url, out_dir)
    system "yt-dlp --output '#{out_dir}/%(title)s.%(ext)s' #{SPONSORBLOCK} '#{url}'"
  end
end
