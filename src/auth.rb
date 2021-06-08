require 'clipboard'
require 'launchy'
require_relative 'server'

puts ''
puts ' → Authenticating with Spotify...'
puts ''
Server.run! port: 3000, quiet: true do |server|
  Launchy.open "http://localhost:3000"
  Thread.new do
    sleep 1 until Server.user_json
    server.shutdown
  end
end

puts ''
puts ' → OK! Copying `SPOTIFY_USER` to your clipboard.'
puts ''
Clipboard.copy Base64.encode64(Server.user_json)
