FROM ruby:2.7-slim AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle config set --local without 'development test' \
    && bundle install --jobs 4 --retry 3

# -------------------------------------------------------

FROM ruby:2.7-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpq5 \
        nodejs \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

ENV PORT=3000 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . /app

RUN useradd -m app && chown -R app:app /app
USER app

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
