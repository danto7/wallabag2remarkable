FROM ruby:3-buster
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
    mkdir -p /app/config /app/.cache/rmapi
ENV CONFIG_FILE="/app/config/config.json" RMAPI_CONFIG="/app/config/rmapi" XDG_CACHE_HOME="/app/config"
VOLUME /app/config
COPY *.rb ./
CMD ["ruby", "./run.rb"]
