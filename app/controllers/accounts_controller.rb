class AccountsController < ApplicationController
  # IMPERSONATION NOTE: this controller does NOT yet respect
  # impersonation. TODO mirror the same gap as TenantsController.

  before_action :load_account, only: %i[show edit update destroy]

  def index
    @accounts = Account.includes(:tenant).order(:name).limit(200)
  end

  def show
  end

  def new
    @account = Account.new(tenant_id: params[:tenant_id])
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      audit!('account.create', target_type: 'Account', target_id: @account.id, payload: account_params)
      redirect_to @account, notice: 'account created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      audit!('account.update', target_type: 'Account', target_id: @account.id, payload: account_params)
      redirect_to @account, notice: 'account updated'
    else
      render :edit
    end
  end

  def destroy
    @account.update(status: 'closed')
    audit!('account.close', target_type: 'Account', target_id: @account.id)
    redirect_to accounts_path, notice: 'account closed'
  end

  private

  def load_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :tenant_id, :status,
                                    :branding_logo_url, :branding_color_hex)
  end
end
