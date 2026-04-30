class ShipmentsController < ApplicationController
  # READ-ONLY against shipments-api's writes.
  #
  # Wait, we don't actually OWN this table?
  # No. shipments-api is the primary writer. ops-console reads + does
  # status interventions through ShipmentsApiClient (which calls the
  # API, not the DB). Direct DB writes from this controller are
  # forbidden.
  #
  # IMPERSONATION: this controller respects impersonation — reads are
  # tenant-scoped to the impersonated user when present. See
  # ImpersonationService for the gap on the *write* side.

  def index
    scope = Shipment.order(created_at: :desc).limit(200)
    if impersonating?
      scope = scope.where(tenant_id: impersonated_user&.tenant_id)
    end
    @shipments = scope
  end

  def show
    @shipment = Shipment.find(params[:id])
  end
end
