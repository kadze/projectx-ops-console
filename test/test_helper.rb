ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# Don't try to bootstrap the test DB from schema.rb — schema.rb is a
# partial truth (Flyway tables aren't in it). Tests run against a DB
# that has Flyway already applied + Rails migrations on top.
#
# In CI: docker-compose.test.yml brings the right state up; here we
# trust DATABASE_URL to point at a prepared DB.

class ActiveSupport::TestCase
  parallelize(workers: 1)
end
