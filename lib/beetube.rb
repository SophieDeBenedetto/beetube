require 'pry'
require 'google/apis'
require 'google/apis/youtube_v3'
class BeeTube
  def self.run(channel_id)
    service = setup_service
    playlist_id = get_playlist_id_for_channel(channel_id)
    playlist_videos = collect_playlist_videos(playlist_id)
    print_video_details(playlist_videos)
  end

  private

  def self.setup_service
    service = Google::Apis::YoutubeV3::YouTubeService.new
    service.key = ENV["GOOGLE_API_KEY"]
    service
  end

  def self.get_playlist_id_for_channel(channel_id)
    service.list_channels("contentDetails", id: channel_id)
    channel_response.items.first.content_details.related_playlists.uploads
  end

  def self.get_playlist_videos(playlist_id)
    results = service.list_playlist_items("contentDetails", playlist_id: playlist_id, max_results: 50)
    playlist_items = []

    playlist_items += results.items

    while results.next_page_token do
      results = service.list_playlist_items("contentDetails", playlist_id: playlist_id, max_results: 50, page_token: results.next_page_token)
      playlist_items += results.items
    end
    playlist_items
  end

  def self.print_video_details(playlist_videos)
    playlist_videos.each do |video|
      get_video_details(video)
    end
  end

  def self.get_video_details(video)
    video_id = video.content_details.video_id
    video_response = service.list_videos("snippet, statistics", id: video_id)
    title = video_response.items.first.snippet.title
    view_count = video_response.items.first.statistics.view_count
    puts "Title: #{title}, View Count: #{view_count}\n"
    # file = CSV.create("the name of the file")
    # file.headers(["video name", "view count"])
    # file.row(title, view_count)
  end
end
