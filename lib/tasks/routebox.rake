namespace :routebox do
  desc 'Seed dev with a tenant + account + sample shipments. Fixes the seeded-data-vs-schema mismatch noted in the README.'
  task dev_seed_tenant: :environment do
    abort 'refusing to run in production' if Rails.env.production?

    tenant = Tenant.find_or_create_by!(slug: 'demo-tenant') do |t|
      t.name = 'Demo Tenant'
      t.billing_plan = 'standard'
      t.status = 'active'
    end

    account = Account.find_or_create_by!(tenant_id: tenant.id, name: 'Demo Account') do |a|
      a.status = 'active'
    end

    user = User.find_or_create_by!(email: 'demo-user@routebox.invalid') do |u|
      u.tenant_id  = tenant.id
      u.account_id = account.id
      u.role       = 'admin'
      u.status     = 'active'
    end

    admin = AdminUser.find_or_create_by!(email: 'ops@routebox.invalid') do |a|
      a.password_digest = '$2a$10$placeholderdigestforlocaldevuseonly1234567890ab'
      a.role = 'admin'
    end

    if Shipment.where(tenant_id: tenant.id).count.zero?
      3.times do |i|
        Shipment.create!(
          tenant_id:  tenant.id,
          account_id: account.id,
          weight_kg:  1.5 + i,
          status:     'created',
          created_by_admin_id: admin.id,
        )
      end
    end

    puts "[dev_seed_tenant] tenant=#{tenant.id} account=#{account.id} user=#{user.id} admin=#{admin.id}"
  end

  desc 'Run the warehouse sync job once (manual trigger).'
  task warehouse_sync_once: :environment do
    WarehouseSyncJob.perform_now
  end
end
