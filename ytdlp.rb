OPTIONS = '--sponsorblock-mark default --embed-thumbnail --recode-video mkv -S "res:1440,fps"'

class Ytdlp
  def download(url, out_dir)
    system "yt-dlp --output '#{out_dir}/%(title)s.%(ext)s' #{OPTIONS} '#{url}'"
  end
end
