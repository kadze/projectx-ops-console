class BillingReconciliationJob < ApplicationJob
  queue_as :billing

  # Nightly. For each open invoice, reconcile against shipment_events
  # written by tracking-events. We pull the events directly from the
  # DB (Flyway-managed table; we read it via raw SQL since it's not
  # an AR-modeled table here).
  def perform
    today = Date.current
    BillingInvoice.where(status: 'open').find_each do |invoice|
      reconcile_invoice(invoice, today)
    end
  end

  private

  def reconcile_invoice(invoice, today)
    sql = <<~SQL
      SELECT count(*)::bigint AS n
      FROM shipment_events se
      JOIN shipments s ON s.id = se.shipment_id
      WHERE s.account_id = $1
        AND se.event_type = 'delivered'
        AND se.occurred_at::date BETWEEN $2 AND $3
    SQL
    res = ApplicationRecord.connection.exec_query(
      sql, 'reconcile', [invoice.account_id, invoice.period_start, [invoice.period_end, today].min],
    )
    delivered_count = res.first['n'].to_i

    invoice.update_column(
      :metadata,
      invoice.metadata.merge('reconciled_delivered_count' => delivered_count, 'reconciled_at' => Time.current.iso8601),
    )
  end
end
