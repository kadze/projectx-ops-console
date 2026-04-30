require 'test_helper'

class ShipmentTest < ActiveSupport::TestCase
  setup do
    @tenant  = Tenant.create!(name: 'T', slug: "t-#{SecureRandom.hex(4)}")
    @account = Account.create!(tenant_id: @tenant.id, name: 'A')
  end

  test 'rejects new ops-console shipment without created_by_admin_id' do
    s = Shipment.new(tenant_id: @tenant.id, account_id: @account.id, status: 'created')
    refute s.valid?
    assert_includes s.errors[:created_by_admin_id],
                    'is required for ops-console-authored shipments'
  end

  test 'allows update of a shipments-api-authored row without created_by_admin_id' do
    # Simulate shipments-api creating the row directly via SQL.
    raw_sql = <<~SQL
      INSERT INTO shipments (tenant_id, account_id, status, created_at, updated_at)
      VALUES (#{@tenant.id}, #{@account.id}, 'created', NOW(), NOW())
      RETURNING id
    SQL
    inserted = ApplicationRecord.connection.exec_query(raw_sql).first['id']

    s = Shipment.find(inserted)
    assert_nil s.created_by_admin_id

    # The retrofitted skip-validation branch lets us update freely.
    s.tracking_number = 'TEST-XYZ'
    assert s.save, "expected save to succeed but: #{s.errors.full_messages}"
  end

  test 'sets internal_status default on save' do
    admin_id = AdminUser.create!(email: "test-#{SecureRandom.hex(4)}@x", role: 'admin').id
    s = Shipment.create!(tenant_id: @tenant.id, account_id: @account.id,
                         status: 'created', created_by_admin_id: admin_id)
    assert_equal 'none', s.internal_status
  end
end
