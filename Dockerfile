FROM ruby:3-buster
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y vim smbclient python3-pip ffmpeg && \
    apt-get clean -y && \
    pip3 install --no-cache-dir yt-dlp
COPY ./rmapi /usr/local/bin/
RUN mkdir /app && \
    groupadd ruby && \
    useradd --home-dir /app -g ruby ruby && \
    chown ruby:ruby /app
WORKDIR /app
USER ruby
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundler install && \
    mkdir -p /app/config /app/.cache/rmapi /app/video_download
ENV CONFIG_FILE="/app/config/config.json" RMAPI_CONFIG="/app/config/rmapi.conf" XDG_CACHE_HOME="/app/config" YT_DOWNLOAD_URL="/app/video_download"
VOLUME /app/config
COPY *.rb ./
CMD ["ruby", "./run.rb"]
