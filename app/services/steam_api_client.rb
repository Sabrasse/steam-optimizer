require 'open-uri'
require 'json'

class SteamApiClient
  API_URL = "http://store.steampowered.com/api/appdetails"

  # Extracts the numeric App ID from a Steam store URL or returns the input if it's already an ID
  def self.extract_app_id(input)
    # If the input is a full URL (e.g. "https://store.steampowered.com/app/480/GameName/"), extract the ID
    if input.match?(/store\.steampowered\.com\/app\//)
      # Use regex to find the digits after "/app/"
      if input =~ /\/app\/(\d+)/
        return $1 # $1 is the first capture group (the App ID)
      end
    end
    # If not a URL, assume it's already an app ID (could be numeric string)
    input
  end

  # Fetches game data from the Steam Store API for the given app_id.
  # Returns a Hash of game data (similar to the "data" field from API) or nil if not found.
  def self.fetch_game_data(app_id)
    return nil if app_id.nil? || app_id.empty?

    url = "#{API_URL}?appids=#{app_id}&l=en"
    begin
      response = URI.open(url).read
      json = JSON.parse(response)
    rescue StandardError => e
      Rails.logger.error "Steam API fetch failed for App ID #{app_id}: #{e.message}"
      return nil
    end

    # The API returns a JSON with the app ID as the key
    info = json[app_id.to_s]
    return nil if info.nil? || info["success"] == false

    data = info["data"]
    # We expect keys like "name", "short_description", "about_the_game", "genres", "categories"
    data
  end
end 