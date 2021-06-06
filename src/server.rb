require 'rspotify'
require 'rspotify/oauth'
require 'sinatra/base'

ID = ENV['SPOTIFY_CLIENT_ID']
SECRET = ENV['SPOTIFY_CLIENT_SECRET']

class Server < Sinatra::Base
  class << self
    attr_accessor :user_json
  end

  configure do
    use Rack::Session::Cookie, secret: SECRET
    enable :sessions
    RSpotify.authenticate ID, SECRET
    use OmniAuth::Builder do
      provider :spotify, ID, SECRET, scope: 'user-library-read playlist-modify-public playlist-modify-private'
    end
  end

  get '/' do
    <<-HTML
      <!DOCTYPE html>
      <form action='/auth/spotify' method='post'>
        <input type="hidden" name="authenticity_token" value="#{env['rack.session'][:csrf]}" />
        <input type='submit' value='Sign in with Spotify' autofocus/>
      </form>
    HTML
  end

  get '/auth/spotify/callback' do
    content_type :json
    Server.user_json = RSpotify::User.new(request.env['omniauth.auth']).to_hash.to_json
  end
end
