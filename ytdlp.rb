class Ytdlp
  @sponsorblock = "--sponsorblock-remove=sponsor --sponsorblock-mark=all"

  def download(url, out_dir)
    system "yt-dlp --output '#{out_dir}/%(title)s.%(ext)s' #{@sponsorblock} '#{url}'"
  end
end
