# frozen_string_literal: true

# Main application helper, global helpers go here
module ApplicationHelper
  def logged_in?
    session['oauth_token'].present?
  end
end
