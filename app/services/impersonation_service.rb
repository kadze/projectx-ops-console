# Impersonation. Lets an admin act as a customer user for support
# workflows.
#
# WHAT WORKS:
#   - read paths in BillingController and ShipmentsController scope by
#     impersonated_user.tenant_id / account_id
#   - `current_admin` stays as the admin (so authorization checks that
#     ask "is this person staff?" still pass)
#   - audit_log entries get an `impersonating_user_id` field in the
#     payload so the impersonated user is at least findable
#
# WHAT'S BROKEN:
#   - audit_log.actor_user_id stores the IMPERSONATOR's user_id, not
#     the impersonated user's. Reports that filter audit_log by
#     "actions taken by user X" miss actions taken on X's behalf via
#     impersonation. Customer support has hit this twice on
#     compliance asks. We've worked around it with the payload field.
#   - TenantsController and AccountsController do NOT consult the
#     impersonation context at all. Writes from those controllers
#     always go through the admin's identity. By design, mostly —
#     but the README's "inconsistent which controllers respect
#     impersonation" line is because of these two.
#   - JWT minting for the impersonated user (so we can call
#     shipments-api as them) is not implemented. Status-intervention
#     paths sign JWTs with the JWT_SIGNING_KEY locally — see
#     mint_user_jwt below — but it's stubby.
#
# Long-term: we want this to be a single guard at the controller level
# that says "impersonation is on, every query is the impersonated user."
# We're not there.
class ImpersonationService
  def self.start!(session:, admin:, user:)
    raise 'no admin' unless admin
    raise 'no user'  unless user
    session[:impersonated_user_id] = user.id
    session[:impersonation_started_at] = Time.current.iso8601
  end

  def self.stop!(session:)
    session.delete(:impersonated_user_id)
    session.delete(:impersonation_started_at)
  end

  # Sign a short-lived JWT representing the impersonated user, used by
  # ShipmentsApiClient for write paths. We sign with HS256 against the
  # same JWT_SIGNING_KEY that shipments-api verifies with — that's the
  # contract; if the signing key rotates, both services need a deploy.
  def self.mint_user_jwt(user:, ttl_seconds: 60)
    require 'jwt'
    key = ENV['JWT_SIGNING_KEY']
    return nil if key.blank?
    payload = {
      sub:        user.id.to_s,
      email:      user.email,
      tenant_id:  user.tenant_id,
      account_id: user.account_id,
      role:       user.role,
      iat:        Time.now.to_i,
      exp:        Time.now.to_i + ttl_seconds,
    }
    JWT.encode(payload, key, 'HS256')
  end
end
