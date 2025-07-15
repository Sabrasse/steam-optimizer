class SteamImagesController < ApplicationController
  def analyze
    @game = Game.find(params[:game_id])
    @image_url = params[:image_url]

    if @image_url.present?
      suggester = AiImageSuggester.new
      @suggestions = suggester.suggest_capsule_image_improvements(@image_url)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'steam_images/analysis_results' }
    end
  end
end 