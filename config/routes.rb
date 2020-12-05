# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get '/', to: 'health_check#index'

  resource :user, except: %i[new edit]
  post 'login', to: 'sessions#create'

  resources :bridges do
    patch 'activate'
    patch 'deactivate'
  end

  resources :headers, :environment_variables, only: :destroy

  post 'events/abort', to: 'events#abort'
  post 'events/:bridge_id', to: 'events#create'
  get 'events', to: 'events#index'
  get 'events/:event_id', to: 'events#show'
  delete 'events/:event_id', to: 'events#destroy'

  post '/contact_us', to: 'contact_us#create'

  mount Sidekiq::Web => '/sidekiq'
end
