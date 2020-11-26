# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get '/', to: 'health_check#index'

  resource :user, except: %i[new edit]

  resources :bridges do
    patch 'activate'
    patch 'deactivate'
  end

  resources :headers, :environment_variables, only: :destroy

  post 'events/(:id)/abort', to: 'events#abort'
  patch 'events/:bridge_id', to: 'events#create'
  resources :events, except: %i[new edit create]

  post 'login', to: 'sessions#create'

  mount Sidekiq::Web => '/sidekiq'
end
