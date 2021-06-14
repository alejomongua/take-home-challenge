# frozen_string_literal: true

# Helpers for videos views
module VideosHelper
  PLAYER_KEY = Rails.application.credentials[:player_key]

  # Renders iframe tag with video player
  def player(video, access_token = '')
    premium = video['subscription_required']
    query_string = premium ? "access_token=#{access_token}" : "api_key=#{PLAYER_KEY}"
    tag.iframe src: "https://player.zype.com/embed/#{video['_id']}.html?#{query_string}", class: 'w-96 h-56'
  end

  def thumbnail(video)
    if video['thumbnails'].is_a?(Array) && !video['thumbnails'].empty?
      # Discard thumbnails too small
      thumbs = video['thumbnails'].reject { |thumbnail| thumbnail['width'] < 288 }

      # If there aren't big thumbnails, take the first one
      return image_tag video['thumbnails'].last if thumbs.empty?

      # Sort by size and take the smallest
      thumb = video['thumbnails'].min_by { |thumbnail| thumbnail['width'] }
      image_tag thumb['url'], class: 'object-cover w-72 h-48'
    else
      # Show placeholder
      image_tag 'no-image.png', class: 'object-cover w-72 h-48'
    end
  end
end
