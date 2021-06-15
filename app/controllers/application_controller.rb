# frozen_string_literal: true

# Functions used in several controllers
class ApplicationController < ActionController::Base
  # Retrive credentials from secret storage
  CLIENT_ID = Rails.application.credentials[:oauth_client_id]
  CLIENT_SECRET = Rails.application.credentials[:oauth_client_secret]

  before_action :check_token

  def parse_response(raw_response, context)
    JSON.parse(raw_response.read_body)
  rescue JSON::ParserError, JSON::ParserException
    Rails.logger.info("Unexpected response: [#{context}] #{raw_response.read_body}")
    flash.alert = 'There was an error logging in, please contact support'
    redirect_to(login_path)
    nil
  end

  def clear_credentials
    session.delete('oauth_token')
    session.delete('refresh_token')
    session.delete('created_at')
  end

  def make_login_request(url, request_params)
    # Set the request
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    # Merge params with oauth credentials
    request.body = request_params.merge(client_id: CLIENT_ID, client_secret: CLIENT_SECRET).to_json

    # Return raw response
    http.request(request)
  end

  private

  # Checks if token is still valid, renew it if it is newer than 2 weeks
  def check_token
    # Return if there are no tokens
    return if session['oauth_token'].nil?

    # If the token is older than two weeks, delete it
    if session['created_at'] < (Time.zone.now - 2.weeks).to_i
      clear_credentials
      return
    end

    # Make API request to renew the token
    url = URI('https://login.zype.com/oauth/token')
    raw_response = make_login_request(url, refresh_token: session['refresh_token'], grant_type: 'refresh_token')

    # Check if response is successful
    unless raw_response.is_a?(Net::HTTPSuccess)
      clear_credentials
      return
    end

    # Try to parse the response
    parsed_response = parse_response(raw_response, 'check_login')

    # If the response cannot be parsed, there is something wrong, but the parsing
    # functions logs the error, shows an alert to the user and redirects
    unless parsed_response
      clear_credentials
      return
    end

    # Set tokens on session
    # TO DO: Persist it, maybe in Redis
    session['oauth_token'] = parsed_response['access_token']
    session['refresh_token'] = parsed_response['refresh_token']
  end
end
