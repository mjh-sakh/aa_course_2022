Rails.application.routes.draw do
  use_doorkeeper
  devise_for :accounts, controllers: {
    registrations: 'accounts/registrations',
    sessions: 'accounts/sessions'
  }

  root to: 'accounts#index'

  resources :accounts, only: [:edit, :destroy]
  put '/accounts/:id', to: 'accounts#enable'
  patch '/accounts/:id', to: 'accounts#update'
  get '/accounts/current', to: 'accounts#current'
  get '/accounts/sign_out', to: 'accounts#sign_in'
  get '/accounts/resend_all_active_accounts',
      to: 'accounts#resend_all_active_accounts',
      as: :resend_data
end
