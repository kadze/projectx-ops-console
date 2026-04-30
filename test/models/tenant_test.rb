require 'test_helper'

class TenantTest < ActiveSupport::TestCase
  test 'requires name and slug' do
    t = Tenant.new
    refute t.valid?
    assert_includes t.errors[:name], "can't be blank"
    assert_includes t.errors[:slug], "can't be blank"
  end

  test 'rejects unknown billing plan' do
    t = Tenant.new(name: 'X', slug: 'x', billing_plan: 'bogus', status: 'active')
    refute t.valid?
    assert_includes t.errors[:billing_plan], 'is not included in the list'
  end
end
