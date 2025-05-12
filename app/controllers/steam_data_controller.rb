class SteamDataController < ApplicationController
  # This controller serves JSON endpoints for Steam data or analysis.
  # GET /steam_data/:appid - returns raw Steam data (or analysis) in JSON format
  def show
    app_id = params[:appid].to_s
    data = SteamApiClient.fetch_game_data(app_id)

    if data.nil?
      render json: { error: "App ID #{app_id} not found or no data available" }, status: :not_found
    else
      # For now, just return the raw data. This can be extended to processed analysis results.
      render json: data
    end
  end
end 