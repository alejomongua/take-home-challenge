# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Videos', type: :request do
  describe 'GET /home' do
    it 'returns http success' do
      # I should mock the API, but I won't by now
      get '/'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      # I should mock the API, but I won't by now
      get '/videos/56a7b83069702d2f830fd9b7'
      expect(response).to have_http_status(:success)
    end
  end
end
