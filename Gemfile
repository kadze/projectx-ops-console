# Gemfile for routebox-ops-console.
#
# Pinned tight. We're on Ruby 2.7 (EOL) because the migration to 3.x is
# tied up with the Rails-to-Flyway migration story (see README) and
# nobody has owned both at once.

source 'https://rubygems.org'

ruby '~> 2.7.8'

gem 'rails', '~> 6.1.7'

# Postgres + connection pool. pg 1.5 is the highest 2.7-compatible major.
gem 'pg', '~> 1.5.4'

# Sidekiq for background jobs. Pinned to a 6.x — newer 7.x dropped Ruby
# 2.7 support so we can't bump without crossing the Ruby version line.
gem 'sidekiq',           '~> 6.5.10'
gem 'sidekiq-scheduler', '~> 5.0.3'
gem 'redis',             '~> 4.8.0'

# Migration safety. The author of this gem has been quiet for a long
# time — see README "The migration gem." We pinned to 0.7.x and never
# moved. Newer versions changed the API; upgrading is in the
# "warm-up project" pile.
gem 'strong_migrations', '~> 0.7.9'

# AWS SDK — only secretsmanager. Used at boot by the secrets_loader
# initializer. Don't pull in the full aws-sdk gem (multi-hundred-MB).
gem 'aws-sdk-secretsmanager', '~> 1.74'

# JWT verification (we accept tokens minted by shipments-api when an
# operator is acting on a customer's behalf via the impersonation flow).
gem 'jwt', '~> 2.7'

# HTTP client for shipments_api_client.
gem 'faraday',            '~> 2.7.10'
gem 'faraday-retry',      '~> 2.2'

# Templating + form helpers.
gem 'puma',          '~> 5.6.7'
gem 'jbuilder',      '~> 2.11'
gem 'bootsnap',      '~> 1.16', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'web-console',  '~> 4.2'
  gem 'listen',       '~> 3.8'
  gem 'spring',       '~> 4.1'
end

group :test do
  gem 'webmock',                      '~> 3.18', require: false
  gem 'rails-controller-testing',     '~> 1.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem.
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Pin transitive deps that have started requiring Ruby 3+ — we're on 2.7.
gem 'ffi',         '< 1.17'
gem 'concurrent-ruby', '< 1.3.5'
