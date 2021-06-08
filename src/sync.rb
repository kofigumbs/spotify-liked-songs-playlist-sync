require 'base64'
require 'json'
require 'rspotify'

SPOTIFY_CLIENT_ID = ENV.fetch 'SPOTIFY_CLIENT_ID'
SPOTIFY_CLIENT_SECRET = ENV.fetch 'SPOTIFY_CLIENT_SECRET'
SPOTIFY_PLAYLIST_NAME = ENV.fetch 'SPOTIFY_PLAYLIST_NAME'
SPOTIFY_USER = ENV.fetch 'SPOTIFY_USER'

RSpotify.authenticate SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET
USER = RSpotify::User.new JSON.parse(Base64.decode64(SPOTIFY_USER))

offset = 0
groups = []
loop do
  tracks = USER.saved_tracks offset: offset, limit: 50
  break if tracks.empty?
  groups.push tracks
  offset += tracks.count
end

offset = 0
playlist = nil
loop do
  playlists = USER.playlists offset: offset, limit: 50
  playlist = playlists.find { |x| x.name == SPOTIFY_PLAYLIST_NAME }
  break if playlist || playlists.empty?
  offset += playlists.count
end

playlist ||= USER.create_playlist! PLAYLIST_NAME, public: false
playlist.replace_tracks! []
groups.each { |tracks| playlist.add_tracks! tracks }
