# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  describe 'GET /home' do
    it 'returns http success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/videos/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/videos/show'
      expect(response).to have_http_status(:success)
    end
  end
end
