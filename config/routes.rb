# frozen_string_literal: true

Rails.application.routes.draw do
  get 'auth/login', as: :login
  post 'auth/do_login', as: :do_login
  post 'auth/logout', as: :logout
  root 'videos#home'
  # get 'videos', to: 'videos#index', as: :videos
  get 'videos/:id', to: 'videos#show', as: :video
end
