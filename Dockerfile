# Dockerfile for routebox-ops-console.
#
# Single-stage. Ruby 2.7 (EOL — see README "The migration gem"). Runs
# as root. No HEALTHCHECK. The COPY-then-bundle-install order means
# any source change busts the bundle cache. We've been meaning to
# split it. We have not.

FROM ruby:2.7

WORKDIR /app

# System deps for pg gem + a few libs Rails defaults pull in.
RUN apt-get update \
    && apt-get install -y \
       build-essential \
       libpq-dev \
       git \
       nodejs \
       postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy everything first so any change busts the bundle layer.
COPY . /app

RUN bundle config set --local without 'development test' \
    && bundle install --jobs 4

ENV PORT=3000 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

EXPOSE 3000

# No HEALTHCHECK — the ALB target group does its own.
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
