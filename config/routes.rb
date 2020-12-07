# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get '/', to: 'health_check#index'

  resource :user, except: %i[new edit]
  get '/user/valid', to: 'users#valid'
  post 'login', to: 'sessions#create'

  resources :bridges, param: :slug do
    patch 'activate'
    patch 'deactivate'
  end

  resources :headers, :environment_variables, only: :destroy

  patch 'events/abort', to: 'events#abort'
  post 'events/:bridge_slug', to: 'events#create'
  get 'events', to: 'events#index'
  get 'events/:event_id', to: 'events#show'
  delete 'events/:event_id', to: 'events#destroy'

  mount Sidekiq::Web => '/sidekiq'
end
