require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.cache_store = :memory_store

  config.action_controller.perform_caching = false
  config.action_controller.enable_fragment_cache_logging = true

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.log_level = ENV.fetch('LOG_LEVEL', 'debug')
  config.hosts.clear
end
