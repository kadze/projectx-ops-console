# Sidekiq config. Single process, single node — see README "Known issues."

require 'sidekiq'

redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

Sidekiq.configure_server do |cfg|
  cfg.redis = { url: redis_url }
end

Sidekiq.configure_client do |cfg|
  cfg.redis = { url: redis_url }
end
