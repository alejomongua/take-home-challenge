# frozen_string_literal => true
require 'uri'
require 'net/http'
require 'openssl'

# Retrieves information about videos from API
# The object has the following format:
#   {
#     '_id' => 'string',
#     'created_at' => 'string',
#     'deleted_at' => 'string',
#     'updated_at' => 'string',
#     'on_air' => true,
#     'purchase_price' => 0,
#     'purchase_required' => true,
#     'rating' => 0,
#     'related_playlist_ids' => [],
#     'rental_duration' => 0,
#     'rental_price' => 0,
#     'rental_required' => true,
#     'request_count' => 0,
#     'site_id' => 'string',
#     'status' => 'string',
#     'crunchyroll_id' => 'string',
#     'hulu_id' => 'string',
#     'mrss_id' => 'string',
#     'kaltura_id' => 'string',
#     'vimeo_id' => 'string',
#     'youtube_id' => 'string',
#     'thumbnails' => [],
#     'transcoded' => true,
#     'video_zobjects' => [],
#     'active' => true,
#     'discovery_url' => 'string',
#     'custom_thumbnail_url' => 'string',
#     'subscription_ads_enabled' => true,
#     'title' => 'string',
#     'zobject_ids' => [],
#     'country' => 'string',
#     'description' => 'string',
#     'short_description' => 'string',
#     'disable_at' => 'string',
#     'enable_at' => 'string',
#     'episode' => 0,
#     'season' => 0,
#     'featured' => true,
#     'friendly_title' => 'string',
#     'keywords' => [],
#     'marketplace_ids' => {},
#     'preview_ids' => [],
#     'mature_content' => true,
#     'pass_required' => true,
#     'published_at' => 'string',
#     'subscription_required' => true,
#     'registration_required' => true,
#     'custom_attributes' => {},
#     'categories_attributes' => [],
#     'segments' => [],
#     'images_attributes' => [],
#     'content_rules' => [],
#     'manifest' => 'string'
#   }
module VideosHelper
  PLAYER_KEY = Rails.application.credentials[:player_key]
  API_KEY = Rails.application.credentials[:app_key]

  # Returns a list of video objects
  def list
    url = URI("https://api.zype.com/videos?api_key=#{API_KEY}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'

    response = http.request(request)
    return [] if response.code != '200'

    response.read_body
  end

  # Returns a single video object based on its ID
  def details(id)
    url = URI("https://api.zype.com/videos/#{id}?api_key=#{API_KEY}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'

    response = http.request(request)
    return {} if response != '200'

    response.read_body
  end

  # Renders iframe tag with video player
  def player(video, access_token = '')
    premium = video['subscription_required']
    query_string = premium ? "access_token=#{access_token}" : "api_key=#{PLAYER_KEY}"
    tag :iframe, src: "https://player.zype.com/embed/#{video['_id']}.html?#{query_string}"
  end

  # Validating if a consumer is entitled to play a video
  def is_entitled?(video, access_token)
    url = URI("https://api.zype.com/videos/#{video['_id']}/entitled?access_token=#{access_token}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'

    response = http.request(request)
    response.read_body
  end
end
