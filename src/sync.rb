require 'base64'
require 'json'
require 'rspotify'

RSpotify.authenticate ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET']
USER = RSpotify::User.new JSON.parse(Base64.decode64(ENV['SPOTIFY_USER']))
PLAYLIST_NAME = ENV['SPOTIFY_PLAYLIST_NAME'].strip

offset = 0
groups = []
loop do
  tracks = USER.saved_tracks offset: offset, limit: 50
  break if tracks.empty?
  groups.push tracks
  offset += tracks.count
end

playlist = USER.playlists(limit: 50).find do |playlist|
  playlist.owner == USER && playlist.name == PLAYLIST_NAME
end
playlist ||= USER.create_playlist! PLAYLIST_NAME, public: false
playlist.replace_tracks! []
groups.each { |tracks| playlist.add_tracks! tracks }
