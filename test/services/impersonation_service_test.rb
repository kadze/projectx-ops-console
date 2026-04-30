require 'test_helper'

class ImpersonationServiceTest < ActiveSupport::TestCase
  setup do
    @session = {}
    @tenant  = Tenant.create!(name: 'T', slug: "t-#{SecureRandom.hex(4)}")
    @account = Account.create!(tenant_id: @tenant.id, name: 'A')
    @admin   = AdminUser.create!(email: "admin-#{SecureRandom.hex(4)}@x", role: 'admin')
    @user    = User.create!(email: "user-#{SecureRandom.hex(4)}@x",
                            tenant_id: @tenant.id, account_id: @account.id, role: 'admin')
  end

  test 'start! and stop! toggle session keys' do
    ImpersonationService.start!(session: @session, admin: @admin, user: @user)
    assert_equal @user.id, @session[:impersonated_user_id]
    ImpersonationService.stop!(session: @session)
    assert_nil @session[:impersonated_user_id]
  end

  test 'mint_user_jwt produces an HS256 token when JWT_SIGNING_KEY is present' do
    key = 'unit-test-jwt-signing-key'
    ENV['JWT_SIGNING_KEY'] = key
    token = ImpersonationService.mint_user_jwt(user: @user)
    refute_nil token
    payload, _header = JWT.decode(token, key, true, algorithm: 'HS256')
    assert_equal @user.id.to_s, payload['sub']
    assert_equal @tenant.id,    payload['tenant_id']
  ensure
    ENV.delete('JWT_SIGNING_KEY')
  end

  test 'mint_user_jwt returns nil if signing key is missing' do
    ENV.delete('JWT_SIGNING_KEY')
    assert_nil ImpersonationService.mint_user_jwt(user: @user)
  end
end
