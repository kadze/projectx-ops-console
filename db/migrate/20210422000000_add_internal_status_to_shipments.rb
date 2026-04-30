class AddInternalStatusToShipments < ActiveRecord::Migration[6.1]
  # ops-console-only column on a shared table. Used by support staff
  # to flag shipments needing intervention. shipments-api ignores this
  # field. Today's Shipment model has a before_save that touches this
  # column on every save — fine when we wrote it, increasingly weird
  # now that shipments-api also writes the row.

  def change
    return if column_exists?(:shipments, :internal_status)
    add_column :shipments, :internal_status, :string
  end
end
