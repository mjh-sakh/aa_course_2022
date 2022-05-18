Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  root to: 'accounting#index'
  get '/login', to: 'accounting#login', as: :login

  get '/accounting', to: 'accounting#index'
  get '/analytics', to: 'analytics#index'
  get '/accounting/calc_and_make_payment',
      to: 'accounting#calc_and_make_payment',
      as: :calc_payment
  patch '/analytics/recalc_users_balances',
        to: 'analytics#recalc_users_balances',
        as: :recalc_balances
end
