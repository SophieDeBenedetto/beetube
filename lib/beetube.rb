require 'pry'
require 'google/apis'
require 'google/apis/youtube_v3'
require "csv"
require 'dotenv/load'
require 'colorize'

class BeeTube
  def self.run(channel_id)
    puts "🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝".yellow.on_black
    puts "🐝🐝🐝🐝🐝🐝WELCOME TO BEETUBE!!!🐝🐝🐝🐝🐝🐝🐝".yellow.on_black
    puts "🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝🐝".yellow.on_black
    service = setup_service
    channel_title, playlist_id = get_playlist_id_for_channel(channel_id, service)
    puts "Fetching videos for channel #{channel_title} 🐝🐝🐝".yellow.on_black
    playlist_videos = get_playlist_videos(playlist_id, service)
    generate_csv(channel_title, playlist_videos, service)
  end

  private

  def self.setup_service
    service = Google::Apis::YoutubeV3::YouTubeService.new
    service.key = ENV["GOOGLE_API_KEY"]
    service
  end

  def self.get_playlist_id_for_channel(channel_identifier, youtube_api)
    channel_response = youtube_api.list_channels("contentDetails, snippet", id: channel_identifier)
    channel_title = channel_response.items.first.snippet.title
    playlist_id = channel_response.items.first.content_details.related_playlists.uploads
    [channel_title, playlist_id]
  end

  def self.get_playlist_videos(playlist_id, youtube_api)
    results = youtube_api.list_playlist_items("contentDetails", playlist_id: playlist_id, max_results: 50)
    playlist_items = []

    playlist_items += results.items

    while results.next_page_token do
      results = youtube_api.list_playlist_items("contentDetails", playlist_id: playlist_id, max_results: 50, page_token: results.next_page_token)
      playlist_items += results.items
    end
    playlist_items
  end

  def self.generate_csv(channel_title, playlist_videos, youtube_api)
    file_name = "#{channel_title.gsub(" ", "_")}.csv"
    CSV.open(file_name, "wb") do |csv|
      csv << ["Title", "View Count", "Comment Count", "Like Count", "Dislike Count"]
      playlist_videos.each do |video|
        csv << get_video_details(video, youtube_api)
      end
    end
    puts "🐝🐝🐝 DONE! 🐝🐝🐝"
    puts "🐝🐝🐝 CSV FILE: #{file_name} 🐝🐝🐝"
  end

  def self.get_video_details(video, youtube_api)
    video_id = video.content_details.video_id
    video_response = youtube_api.list_videos("snippet, statistics", id: video_id)
    title = video_response.items.first.snippet.title
    view_count = video_response.items.first.statistics.view_count
    comment_count = video_response.items.first.statistics.comment_count
    like_count = video_response.items.first.statistics.like_count
    dislike_count = video_response.items.first.statistics.dislike_count
    puts "Adding #{title} stats 🐝🐝🐝".yellow.on_black
    [title, view_count, comment_count, like_count, dislike_count]
  end
end
