class AuditLogsController < ApplicationController
  def index
    @entries = AuditLog.order(recorded_at: :desc).limit(500)
  end

  def show
    @entry = AuditLog.find(params[:id])
  end
end
