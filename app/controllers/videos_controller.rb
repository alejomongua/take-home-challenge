# frozen_string_literal: true

# Video controller, no description needed
class VideosController < ApplicationController
  API_KEY = Rails.application.credentials[:app_key]
  ROOT_API_URL = 'https://api.zype.com/videos'

  def home
    url_string = "#{ROOT_API_URL}?app_key=#{API_KEY}"

    url_string += "&page=#{params[:page]}" if params[:page]

    url = URI(url_string)

    response = make_request(url)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Error requesting to API: [list] #{request.body}")
      @videos = {}
      flash.alert 'There was an error getting the list of videos, please contact support'
      return
    end

    begin
      parsed_response = JSON.parse(response.read_body)
    rescue JSON::ParserError, JSON::ParserException
      Rails.logger.info("Unexpected response: [list] #{request.read_body}")
      @videos = {}
      flash.alert 'There was an error getting the list of videos, please contact support'
      return
    end

    @videos = parsed_response['response'] || {}
    @pagination = parsed_response['pagination']
  end

  # def index; end

  def show
    url = URI("https://api.zype.com/videos/#{params[:id]}?app_key=#{API_KEY}")

    response = make_request(url)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Error requesting to API: [details] #{request.body}")
      return {}
    end

    begin
      parsed_response = JSON.parse(response.read_body)
    rescue JSON::ParserError, JSON::ParserException
      Rails.logger.info("Unexpected response: [details] #{request.read_body}")
      return {}
    end

    @video = parsed_response['response'] || {}
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

  # Validating if a consumer is entitled to play a video
  def entitled?(video, access_token)
    url = URI("#{ROOT_API_URL}/#{video['_id']}/entitled?access_token=#{access_token}")

    response = make_request(url)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Error requesting to API: [entitled?] => #{request.body}")
      return ''
    end

    response.read_body
  end
end
