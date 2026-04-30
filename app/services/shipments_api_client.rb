require 'faraday'
require 'faraday/retry'
require 'json'

# Thin client over routebox-shipments-api.
#
# Uses the shared INTERNAL_API_TOKEN that lives at
# routebox/<env>/INTERNAL_API_TOKEN in Secrets Manager. Set into
# ENV['ROUTEBOX_INTERNAL_API_TOKEN'] by config/initializers/secrets_loader.rb.
#
# Used by:
#   - the shipments view (we read DB-side directly there for speed; the
#     intervention path goes through here)
#   - WarehouseSyncJob via legacy_export_csv
class ShipmentsApiClient
  class Error < StandardError; end

  DEFAULT_BASE_URL = ENV.fetch('ROUTEBOX_SHIPMENTS_API_BASE_URL',
                               'http://shipments-api.internal.routebox:3000')

  def initialize(base_url: DEFAULT_BASE_URL,
                 token:    ENV['ROUTEBOX_INTERNAL_API_TOKEN'])
    @base_url = base_url
    @token = token
  end

  # CSV-streamed dump of the shipments table. Customer of
  # routebox-shipments-api/src/routes/internal.js's
  # GET /internal/legacy-export.
  #
  # Returns the body as a string. The job that calls this is
  # WarehouseSyncJob; for very large exports we'd prefer to stream
  # to disk instead of buffer in memory. We've discussed it. Today
  # the export fits in memory.
  def legacy_export_csv
    resp = conn.get('/internal/legacy-export') do |req|
      req.headers['Accept']         = 'text/csv'
      req.headers['X-Triggered-By'] = 'ops-console.warehouse_sync_job'
    end
    raise Error, "legacy-export #{resp.status}" unless resp.success?
    resp.body
  end

  # Status-intervention path. Posts a status transition to a shipment
  # via shipments-api so that the canonical shipment_status_history
  # entry is created with the impersonated user's id.
  def transition_shipment_status(shipment_id:, to_status:, note:, jwt:)
    resp = conn.post("/v1/shipments/#{shipment_id}/status") do |req|
      req.headers['Authorization']  = "Bearer #{jwt}"
      req.headers['Content-Type']   = 'application/json'
      req.body = JSON.generate(to_status: to_status, note: note)
    end
    raise Error, "transition_shipment_status #{resp.status} #{resp.body}" unless resp.success?
    JSON.parse(resp.body)
  end

  private

  def conn
    @conn ||= Faraday.new(url: @base_url) do |f|
      f.headers['X-Internal-Token'] = @token if @token.present?
      f.request :retry, max: 2, interval: 0.5,
                        retry_statuses: [502, 503, 504]
      f.adapter Faraday.default_adapter
    end
  end
end
