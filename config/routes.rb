# frozen_string_literal: true

Rails.application.routes.draw do
  root 'videos#home'
  # get 'videos', to: 'videos#index', as: :videos
  get 'videos/:id', to: 'videos#show', as: :video
end
