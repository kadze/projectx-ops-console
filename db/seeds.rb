# db/seeds.rb
#
# Out-of-date warning: this seed predates the introduction of multi-
# tenant routing in Rails. Some pages 500 on the seeded data unless
# you create a tenant first via the seed rake task:
#
#   bundle exec rake routebox:dev_seed_tenant
#
# We've talked about migrating this file. We have not.

puts "[seeds] creating an admin user…"
AdminUser.find_or_create_by!(email: 'ops@routebox.invalid') do |u|
  u.password_digest = '$2a$10$placeholderdigestforlocaldevuseonly1234567890ab'
  u.role            = 'admin'
end

puts "[seeds] creating a support ticket policy row…"
AdminAuditPolicy.find_or_create_by!(action_pattern: 'shipment.refund') do |p|
  p.verbosity        = 'verbose'
  p.slack_channel    = '#ops-billing'
  p.alert_threshold  = 100_00
end

puts "[seeds] done. run `rake routebox:dev_seed_tenant` to create a tenant + account + sample shipments."
