# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the VideosHelper. For example:
#
# describe VideosHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe VideosHelper, type: :helper do
  describe 'shows player' do
    it 'renders iframe with video player' do
      # Here I should mock the API, but this time I won't
      access_token = 'abc123'
      session['oauth_token'] = access_token
      video = {
        '_id' => '56a7b83069702d2f830fd9b7',
        'subscription_required' => false
      }
      player = helper.player(video)
      expect(player.is_a?(String)).to be_truthy
      expect(player).to include('https://player.zype.com/embed')

      # If it's a premium video it includes access token
      video['subscription_required'] = true
      player = helper.player(video)
      expect(player).to include("access_token=#{access_token}")

      # If it isn't a premium video it includes api_key
      video['subscription_required'] = false
      player = helper.player(video)
      expect(player).to include('api_key=')
    end
  end
end
