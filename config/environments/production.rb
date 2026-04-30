require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.force_ssl = false # ALB does TLS termination

  config.log_level = ENV.fetch('LOG_LEVEL', 'info')
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.logger.formatter = ::Logger::Formatter.new

  config.cache_store = :memory_store

  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false

  # Hosts allowed by Rack::HostAuthorization. ALB sends Host headers we
  # don't enumerate here; we trust the SG perimeter and disable the check.
  config.hosts.clear
end
