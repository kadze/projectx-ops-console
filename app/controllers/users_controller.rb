class UsersController < ApplicationController
  before_action :load_user, only: %i[show edit update destroy]

  def index
    @users = User.includes(:tenant, :account).order(:email).limit(200)
  end

  def show; end
  def edit; end

  def update
    if @user.update(user_params)
      audit!('user.update', target_type: 'User', target_id: @user.id, payload: user_params)
      redirect_to @user, notice: 'user updated'
    else
      render :edit
    end
  end

  def destroy
    @user.update(status: 'closed')
    audit!('user.close', target_type: 'User', target_id: @user.id)
    redirect_to users_path, notice: 'user closed'
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role, :status, :internal_notes, :account_id)
  end
end
