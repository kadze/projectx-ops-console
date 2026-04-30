Rails.application.routes.draw do
  root to: 'tenants#index'

  get   '/login',  to: 'sessions#new',     as: :login
  post  '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :tenants
  resources :accounts
  resources :users

  # Shipments are read-only here. shipments-api owns the writes.
  resources :shipments, only: %i[index show]

  resources :billing,    only: %i[index show]
  resources :audit_logs, only: %i[index show]

  resource :impersonation, only: %i[create destroy]

  get '/health', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"ok":true}']] }
end
