# frozen_string_literal: true

Rails.application.routes.draw do
  resource :user, except: %i[new edit]
  resources :bridges do
    patch 'activate'
    patch 'deactivate'
  end
  resources :headers, :environment_variables, only: :destroy

  post 'login', to: 'sessions#create'
  get 'events', to: 'events#index'
end
