require 'test_helper'
require 'webmock/minitest'

class WarehouseSyncJobTest < ActiveJob::TestCase
  test 'fetches /internal/legacy-export and parses CSV' do
    csv = <<~CSV
      shipment_id,tenant_id,account_name,status,status_description,carrier_code,tracking_number,expected_delivery_at,delivered_at,quoted_amount_cents,quoted_currency,created_at,updated_at
      1,1,Acct,delivered,Delivered,UPS,1Z123,2026-01-01,2026-01-01,1500,USD,2026-01-01,2026-01-01
      2,1,Acct,in_transit,In transit,FDX,FX9,,,2200,USD,2026-01-01,2026-01-01
    CSV

    stub_request(:get, /\/internal\/legacy-export\z/)
      .to_return(status: 200, body: csv, headers: { 'Content-Type' => 'text/csv' })

    assert_nothing_raised { WarehouseSyncJob.new.perform }
  end

  test 'raises when shipments-api returns a non-2xx' do
    stub_request(:get, /\/internal\/legacy-export\z/)
      .to_return(status: 503, body: 'service unavailable')

    assert_raises(ShipmentsApiClient::Error) { WarehouseSyncJob.new.perform }
  end
end
