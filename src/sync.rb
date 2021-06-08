require 'base64'
require 'json'
require 'octokit'
require 'rbnacl'
require 'rspotify'

SPOTIFY_CLIENT_ID = ENV.fetch 'SPOTIFY_CLIENT_ID'
SPOTIFY_CLIENT_SECRET = ENV.fetch 'SPOTIFY_CLIENT_SECRET'
SPOTIFY_PLAYLIST_NAME = ENV.fetch 'SPOTIFY_PLAYLIST_NAME'
SPOTIFY_USER = ENV.fetch 'SPOTIFY_USER'
GITHUB_TOKEN = ENV.fetch 'GITHUB_TOKEN'
GITHUB_REPOSITORY = ENV.fetch 'GITHUB_REPOSITORY'

RSpotify.authenticate SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET
user_hash = JSON.parse Base64.decode64(SPOTIFY_USER)
user_hash['credentials']['access_refresh_callback'] = Proc.new do
  github = Octokit::Client.new access_token: GITHUB_TOKEN
  repository_key = github.get_public_key GITHUB_REPOSITORY
  sodium_key = RbNaCl::PublicKey.new Base64.decode64(repository_key[:key])
  sodium_box = RbNaCl::Boxes::Sealed.from_public_key(sodium_key)
  github.create_or_update_secret GITHUB_REPOSITORY, 'SPOTIFY_USER', {
    key_id: repository_key[:key_id],
    encrypted_value: Base64.strict_encode64(sodium_box.encrypt(Base64.encode64(USER.to_hash.to_json))),
  }
end
USER = RSpotify::User.new user_hash

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

playlist ||= USER.create_playlist! SPOTIFY_PLAYLIST_NAME, public: false
playlist.replace_tracks! []
groups.each { |tracks| playlist.add_tracks! tracks }
