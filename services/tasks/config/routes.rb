# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  root to: "tasks#index"
  get '/tasks', to: 'tasks#index'
  post '/', to: 'tasks#create'
  patch '/shuffle', to: 'tasks#shuffle'
  patch '/task/:id', to: 'tasks#complete'
  get '/login', to: 'tasks#login'
end
