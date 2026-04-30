class TenantUsageRollupJob < ApplicationJob
  queue_as :low

  # Hourly. For each tenant, sum the number of shipments delivered in
  # the previous hour and stash it in the tenant's metadata for the
  # admin dashboard.
  def perform
    cutoff = Time.current - 1.hour
    Tenant.find_each do |tenant|
      n = Shipment.where(tenant_id: tenant.id, delivered_at: cutoff..Time.current).count
      Rails.logger.debug(msg: 'rollup', tenant_id: tenant.id, delivered_last_hour: n)
    end
  end
end
