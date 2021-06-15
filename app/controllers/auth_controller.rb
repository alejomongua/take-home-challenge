# frozen_string_literal: true

# Requests related to authentication
class AuthController < ApplicationController
  def login
    # return_to param is set when the user clicks on a premium video
    # this param is send to the view in a hidden field
    @return_to = params[:return_to]
  end

  def do_login
    # If there is a return_to param, keep it to render it in case
    # authentication fails
    @return_to = params[:return_to]

    # Make API request
    url = URI('https://login.zype.com/oauth/token')
    raw_response = make_login_request(url, username: params[:username], password: params[:password], grant_type: 'password')

    # Check if response is successful
    unless raw_response.is_a?(Net::HTTPSuccess)
      # Inform the user if authentication fails
      flash.alert = 'Invalid username or password'
      redirect_to(login_path)
      return
    end

    # Try to parse the response
    parsed_response = parse_response(raw_response, 'login')

    # If the response cannot be parsed, there is something wrong, but the parsing
    # functions logs the error, shows an alert to the user and redirects
    return unless parsed_response

    # Set tokens on session
    # TO DO: Persist it, maybe in Redis
    session['oauth_token'] = parsed_response['access_token']
    session['refresh_token'] = parsed_response['refresh_token']
    session['created_at'] = parsed_response['created_at']

    # Inform the user
    flash.notice = 'Successfully logged in'

    # If there is a param to redirect, make the redirection to the video, else
    # redirect to root path
    redirect_to @return_to || root_path
  end

  def logout
    # Make the request to the API
    url = URI('https://login.zype.com/oauth/revoke')

    raw_response = make_login_request(url, token: session['oauth_token'])

    # In any case delete the session variables
    clear_credentials

    # Check if the request is successful
    if raw_response.is_a?(Net::HTTPSuccess)
      flash.notice = 'Logged out successfully'
    else
      # If there is something wrong, log it, maybe the token is expired
      Rails.logger.info("Error requesting to API: [logout] => #{raw_response.read_body}")
    end

    # Redirect to root path
    redirect_to root_path
  end
end
