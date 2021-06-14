# frozen_string_literal: true

Rails.application.routes.draw do
  root 'videos#home'
  get 'videos/index'
  get 'videos/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
