class ImpersonationController < ApplicationController
  def create
    user = User.find(params[:user_id])
    ImpersonationService.start!(session: session, admin: current_admin, user: user)
    audit!('impersonation.start',
           target_type: 'User', target_id: user.id,
           payload: { admin_id: current_admin&.id })
    redirect_to user_path(user), notice: "now impersonating #{user.email}"
  end

  def destroy
    ImpersonationService.stop!(session: session)
    audit!('impersonation.stop')
    redirect_to root_path, notice: 'impersonation ended'
  end
end
