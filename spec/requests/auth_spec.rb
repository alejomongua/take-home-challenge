# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auths', type: :request do
  describe 'GET /login' do
    it 'returns http success' do
      get '/auth/login'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Please identify yourself')
    end
  end

  # To do: test logout
  # describe 'POST /logout' do
  #  it 'returns http success' do
  #  end
  # end
end
