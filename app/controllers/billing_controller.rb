class BillingController < ApplicationController
  # IMPERSONATION: this controller respects impersonation. Read scope
  # narrows to the impersonated user's account when present.

  def index
    scope = BillingInvoice.order(period_end: :desc).limit(200)
    if impersonating?
      scope = scope.where(account_id: impersonated_user&.account_id)
    end
    @invoices = scope
  end

  def show
    @invoice = BillingInvoice.find(params[:id])
  end
end
