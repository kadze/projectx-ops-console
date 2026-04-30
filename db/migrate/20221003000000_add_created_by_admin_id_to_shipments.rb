class AddCreatedByAdminIdToShipments < ActiveRecord::Migration[6.1]
  # ops-console can create shipments on behalf of a tenant (support
  # workflow). When it does, this column is set to the admin_user.id.
  # When shipments-api creates a shipment, this column is NULL.
  #
  # The Shipment model has a validation that REQUIRES this column
  # unless `created_by_shipments_api?` returns true. The "skip
  # validation when shipments-api wrote it" branch is one of the
  # retrofitted special cases that Rails-side coexistence requires.

  disable_ddl_transaction!

  def change
    return if column_exists?(:shipments, :created_by_admin_id)
    add_column :shipments, :created_by_admin_id, :bigint
    add_index  :shipments, :created_by_admin_id, algorithm: :concurrently
  end
end
