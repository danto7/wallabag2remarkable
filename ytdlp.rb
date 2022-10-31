SPONSORBLOCK = "--force-keyframes-at-cuts --sponsorblock-remove sponsor --sponsorblock-mark default --embed-thumbnail"

class Ytdlp
  def download(url, out_dir)
    system "yt-dlp --output '#{out_dir}/%(title)s.%(ext)s' #{SPONSORBLOCK} '#{url}'"
  end
end
