class CreateBaseline < ActiveRecord::Migration[6.1]
  # The original Rails baseline. Created tenants/accounts/users/shipments
  # plus reference data. When we introduced Flyway, V001 in
  # routebox-db-migrations re-asserted the same tables (with IF NOT EXISTS),
  # so this migration is now effectively a no-op against any current
  # environment. We kept it for historical legibility.

  def up
    return if table_exists?(:tenants)

    create_table :tenants do |t|
      t.string  :name,         null: false
      t.string  :slug,         null: false
      t.string  :billing_plan, null: false, default: 'standard'
      t.string  :status,       null: false, default: 'active'
      t.timestamps
    end
    add_index :tenants, :slug, unique: true

    create_table :accounts do |t|
      t.bigint  :tenant_id, null: false
      t.string  :name,      null: false
      t.string  :status,    null: false, default: 'active'
      t.timestamps
    end
    add_index :accounts, :tenant_id

    create_table :users do |t|
      t.bigint  :tenant_id,        null: false
      t.bigint  :account_id
      t.text    :email,            null: false
      t.text    :password_digest
      t.string  :role,             null: false, default: 'member'
      t.string  :status,           null: false, default: 'active'
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :users, [:tenant_id]
    add_index :users, 'lower(email)', unique: true, name: 'uniq_users_email_lower'

    create_table :shipments do |t|
      t.bigint     :tenant_id, null: false
      t.bigint     :account_id, null: false
      t.jsonb      :origin_address, null: false
      t.jsonb      :destination_address, null: false
      t.decimal    :weight_kg, precision: 10, scale: 3
      t.string     :status, null: false, default: 'created'
      t.string     :carrier_code
      t.text       :tracking_number
      t.datetime   :expected_delivery_at
      t.datetime   :delivered_at
      t.timestamps
    end
    add_index :shipments, :tenant_id
    add_index :shipments, :account_id
    add_index :shipments, :status
  end

  def down
    drop_table :shipments,   if_exists: true
    drop_table :users,       if_exists: true
    drop_table :accounts,    if_exists: true
    drop_table :tenants,     if_exists: true
  end
end
