require 'csv'

class WarehouseSyncJob < ApplicationJob
  queue_as :warehouse

  # Nightly. Calls shipments-api's GET /internal/legacy-export, parses
  # the CSV, pushes to the data warehouse.
  #
  # See routebox-shipments-api/src/routes/internal.js for the endpoint
  # this is the customer of. If that endpoint goes away, this job
  # breaks. The endpoint owner has been told. The endpoint stays.
  def perform
    csv_text = ShipmentsApiClient.new.legacy_export_csv
    rows = CSV.parse(csv_text, headers: true)

    warehouse_payload = rows.map do |row|
      {
        shipment_id:  row['shipment_id'].to_i,
        account_id:   row['account_name'],
        status:       row['status'],
        delivered_at: row['delivered_at'],
        amount_cents: row['quoted_amount_cents'].to_i,
      }
    end

    push_to_warehouse(warehouse_payload)

    Rails.logger.info(
      msg: 'warehouse-sync ok',
      rows_exported: warehouse_payload.length,
    )
  rescue ShipmentsApiClient::Error => err
    Rails.logger.error msg: 'warehouse-sync failed', err: err.message
    raise
  end

  private

  # The actual warehouse push is a no-op here — the real implementation
  # would `aws s3 cp` to the data team's bucket and notify their
  # Lambda. Intentionally stubby so this repo's test surface stays
  # tractable.
  def push_to_warehouse(payload)
    Rails.logger.info msg: 'warehouse-sync would push', count: payload.length
    payload
  end
end
