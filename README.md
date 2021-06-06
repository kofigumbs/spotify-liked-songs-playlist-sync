1. Create a Spotify application [from Spotify's developer dashboard](https://developer.spotify.com/dashboard/)
2. Add `http://localhost:3000/auth/spotify/callback` to your Spotify application's Redirect URIs
3. Clone locally and run the following one-time setup:
  ```
  bundle check || bundle install
  SPOTIFY_CLIENT_ID= SPOTIFY_CLIENT_SECRET= bundle exec ruby src/auth.rb
  ```
4. Fork this repo and add the following GitHub Action Secrets:
  - `SPOTIFY_USER` - generated from setup above
  - `SPOTIFY_PLAYLIST_NAME` - sync will create a new playlist if it doesn't find one with the matching name)
  - `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET` - [from Spotify's developer dashboard](https://developer.spotify.com/dashboard/)
