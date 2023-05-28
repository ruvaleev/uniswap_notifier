FROM ruby:3.2.2

RUN apt-get update && \
    apt-get install -y build-essential cmake libpq-dev

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

CMD ["bundle", "exec", "sidekiq", "-r", "./app.rb"]
