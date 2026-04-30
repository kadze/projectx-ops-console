require_relative "boot"

require "rails"
# Pull in only the bits we use. We don't have a mailer, action_mailbox,
# or activestorage. Trimmed for boot speed.
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
# We don't use sprockets — the admin console serves inline CSS only.

Bundler.require(*Rails.groups)

module RouteboxOpsConsole
  class Application < Rails::Application
    config.load_defaults 6.1

    config.autoload_paths   << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # Sidekiq for background jobs.
    config.active_job.queue_adapter = :sidekiq

    # We dump db/schema.rb (Ruby format) NOT db/structure.sql. schema.rb
    # is a partial truth for this codebase — it captures what Rails
    # migrations created, but the prod DB also has Flyway-managed
    # tables (carrier_events_raw, route_calculations, etc.) that
    # Rails doesn't know about. Don't be surprised when schema.rb
    # disagrees with `\dt` in psql.
    config.active_record.schema_format = :ruby

    # Time zone — UTC across the company.
    config.time_zone = 'UTC'

    config.api_only = false

    # Don't generate fixtures or routing specs by default.
    config.generators do |g|
      g.test_framework :test_unit, fixture: false
      g.helper false
      g.assets false
    end
  end
end
