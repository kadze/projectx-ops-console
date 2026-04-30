class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_admin_login!
  helper_method :current_admin, :impersonating?, :impersonated_user

  private

  def require_admin_login!
    return if Rails.env.test? && session[:admin_user_id].nil? == false
    redirect_to(login_path) unless current_admin
  end

  def current_admin
    @current_admin ||= AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
  end

  def impersonating?
    session[:impersonated_user_id].present?
  end

  def impersonated_user
    return nil unless impersonating?
    @impersonated_user ||= User.find_by(id: session[:impersonated_user_id])
  end

  # Hand to the audit_log writer. See ImpersonationService for the gap:
  # this writes the IMPERSONATOR's id, not the impersonated user's id.
  def audit!(action, target_type: nil, target_id: nil, payload: {})
    AuditLog.append!(
      actor:       current_admin,
      action:      action,
      target_type: target_type,
      target_id:   target_id,
      payload:     payload.merge(impersonating_user_id: session[:impersonated_user_id]),
    )
  rescue => err
    Rails.logger.error "audit! failed: #{err.class}: #{err.message}"
  end
end
