FROM debian:11-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ruby-full build-essential zlib1g-dev

RUN gem install jekyll bundler

WORKDIR /app

COPY Gemfile .
RUN bundle install

COPY . .

CMD ["jekyll", "serve", "--host", "0.0.0.0"]
