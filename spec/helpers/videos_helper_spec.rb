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
  describe 'list videos' do
    it 'retrieves the list of videos' do
      # Here I should mock the API, but this time I won't
      list = helper.list
      expect(list.is_a?(Array)).to be_truthy
      expect(list.first.is_a?(Hash)).to be_truthy
      expect(list.first).to include('_id')
    end
  end

  describe 'show details of a video' do
    it 'retrieves the list of videos' do
      # Here I should mock the API, but this time I won't
      list = helper.list
      expect(helper.details(list.first['_id']).is_a?(Hash)).to be_truthy
    end
  end

  describe 'shows player' do
    it 'renders iframe with video player' do
      # Here I should mock the API, but this time I won't
      list = helper.list
      access_token = 'abc123'
      video = list.first
      player = helper.player(video, access_token)
      expect(player.is_a?(String)).to be_truthy
      expect(player).to include('https://player.zype.com/embed')

      # If it's a premium video it includes access token
      video['subscription_required'] = true
      player = helper.player(video, access_token)
      expect(player).to include("access_token=#{access_token}")

      # If it isn't a premium video it includes apí_key
      video['subscription_required'] = false
      player = helper.player(video, access_token)
      expect(player).to include('api_key=')
    end
  end
end
