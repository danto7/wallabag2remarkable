FROM ruby:3-buster
RUN mkdir /app && \
    groupadd ruby && \
    useradd --home-dir /app -g ruby ruby && \
    chown ruby:ruby /app
WORKDIR /app
USER ruby
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundler install && \
    mkdir -p config
ENV CONFIG_FILE="/app/config/config.json"
VOLUME /app/config
COPY *.rb ./
CMD ["ruby", "./run.rb"]
