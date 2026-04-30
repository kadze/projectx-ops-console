class TenantsController < ApplicationController
  # IMPERSONATION NOTE: this controller does NOT yet respect
  # impersonation. Writes here always go through the admin's identity.
  # TODO: thread the impersonation context through. We've put it off
  # because most tenant-level actions are admin-only by design and
  # impersonation isn't actually meaningful here. The TODO has been
  # in place a while and the gap has shown up in audits.

  before_action :load_tenant, only: %i[show edit update destroy]

  def index
    @tenants = Tenant.order(:name).limit(200)
  end

  def show
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      audit!('tenant.create', target_type: 'Tenant', target_id: @tenant.id, payload: tenant_params)
      redirect_to @tenant, notice: 'tenant created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tenant.update(tenant_params)
      audit!('tenant.update', target_type: 'Tenant', target_id: @tenant.id, payload: tenant_params)
      redirect_to @tenant, notice: 'tenant updated'
    else
      render :edit
    end
  end

  def destroy
    @tenant.update(status: 'closed')
    audit!('tenant.close', target_type: 'Tenant', target_id: @tenant.id)
    redirect_to tenants_path, notice: 'tenant closed'
  end

  private

  def load_tenant
    @tenant = Tenant.find(params[:id])
  end

  def tenant_params
    params.require(:tenant).permit(:name, :slug, :billing_plan, :status)
  end
end
