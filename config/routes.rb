# frozen_string_literal: true

Rails.application.routes.draw do
  post 'users', to: 'users#create'
  get 'users', to: 'users#show'
  patch 'users', to: 'users#update'
  put 'users', to: 'users#update'
  delete 'users', to: 'users#destroy'
  post 'login', to: 'sessions#create'
<<<<<<< HEAD
  get 'events', to: 'events#index'
=======
>>>>>>> 11d80c27fa5104bb4322e4fb4e3883f0e02bcfa1
end
