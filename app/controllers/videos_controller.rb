# frozen_string_literal: true

# Video controller, no description needed
class VideosController < ApplicationController
  # Set constants
  API_KEY = Rails.application.credentials[:app_key]
  ROOT_API_URL = 'https://api.zype.com/videos'

  def home
    # Make API request
    parsed_response = list(params[:page])

    # If request is successful, show list of videos
    if parsed_response
      @videos = parsed_response['response'] || []
      @pagination = parsed_response['pagination']
    else
      # If there is something wrong, set @videos to an empty array
      # to avoid 500 error codes
      @videos = []
    end
  end

  # def index; end

  def show
    # Check if the user is entitled to see this video
    @entitled = entitled?(params[:id])

    # If it's not entitled, retrieve the video information anyway
    url = URI("https://api.zype.com/videos/#{params[:id]}?app_key=#{API_KEY}")

    raw_response = make_request(url)
    # Check if there is something wrong
    unless raw_response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Error requesting to API: [details] #{raw_response.read_body}")
      flash.alert = 'There was an error, contact support'
      return {}
    end

    parsed_response = parse_response(raw_response, 'show')

    # Set @video to an empty hash to avoid 500 error codes
    @video = if parsed_response
               parsed_response['response'] || {}
             else
               flash.alert = 'There was an error, contact support'
               {}
             end
  end

  private

  # Makes generic GET request
  def make_request(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'

    http.request(request)
  end

  def list(page)
    url_string = "#{ROOT_API_URL}?app_key=#{API_KEY}&sort=created_at&order=desc"

    url_string += "&page=#{page}" if page

    url = URI(url_string)

    raw_response = make_request(url)
    unless raw_response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Error requesting to API: [list] #{raw_response.read_body}")
      @videos = {}
      flash.now.alert = 'There was an error getting the list of videos, please contact support'
      return
    end

    parse_response(raw_response, 'list')
  end

  # Validating if a consumer is entitled to play a video
  def entitled?(video_id)
    return false if session[:oauth_token].nil?

    url = URI("#{ROOT_API_URL}/#{video_id}/entitled?access_token=#{session[:oauth_token]}")

    raw_response = make_request(url)

    # Does not have permission
    return false unless raw_response.is_a?(Net::HTTPSuccess)

    begin
      parsed_response = JSON.parse(raw_response.read_body)
    rescue JSON::ParserError, JSON::ParserException
      Rails.logger.info("Unexpected response: [details] #{raw_response.read_body}")
      return false
    end

    parsed_response['message'] == 'entitled'
  end
end
