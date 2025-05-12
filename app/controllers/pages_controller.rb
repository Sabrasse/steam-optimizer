class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if request.post?
      Rails.logger.debug "Form submitted with params: #{params.inspect}"
      
      # Retrieve the App ID from form input (it may be an ID or a full URL)
      input = params[:app_id].to_s.strip
      Rails.logger.debug "Input received: #{input}"
      
      if input.blank?
        respond_to do |format|
          format.html { redirect_to root_path, alert: "Please enter a Steam App ID or URL." }
          format.turbo_stream { 
            flash.clear
            flash.now[:alert] = "Please enter a Steam App ID or URL."
            render turbo_stream: turbo_stream.replace("flash", partial: "shared/flashes")
          }
        end
        return
      end

      # Use the SteamApiClient service to fetch game data from Steam
      app_id = SteamApiClient.extract_app_id(input)
      Rails.logger.debug "Extracted App ID: #{app_id}"
      
      @game_data = SteamApiClient.fetch_game_data(app_id)
      Rails.logger.debug "Game data fetched: #{@game_data.present?}"

      if @game_data.nil?
        respond_to do |format|
          format.html { redirect_to root_path, alert: "Could not retrieve data for App ID #{app_id}. Please check the ID and try again." }
          format.turbo_stream { 
            flash.clear
            flash.now[:alert] = "Could not retrieve data for App ID #{app_id}. Please check the ID and try again."
            render turbo_stream: turbo_stream.replace("flash", partial: "shared/flashes")
          }
        end
        return
      end

      # Process the game data
      @text_report = TextAnalyzer.new(@game_data).analyze
      @visual_report = VisualAnalyzer.new(@game_data).analyze
      @tags_list = extract_tags(@game_data)
      @tags_score, @tags_feedback = TextAnalyzer.grade_tags(@tags_list)
      @ai_suggestions = generate_ai_suggestions(@game_data)

      respond_to do |format|
        format.html { render :home }
        format.turbo_stream { 
          flash.clear
          render turbo_stream: [
            turbo_stream.replace("flash", partial: "shared/flashes"),
            turbo_stream.replace("results", partial: "results")
          ]
        }
      end
    else
      # Load analysis results from cache if token exists
      if (token = session[:analysis_token])
        if (results = Rails.cache.read("analysis_#{token}"))
          @game_data = results[:game_data]
          @text_report = results[:text_report]
          @visual_report = results[:visual_report]
          @tags_list = results[:tags_list]
          @tags_score, @tags_feedback = TextAnalyzer.grade_tags(@tags_list)
          @ai_suggestions = results[:ai_suggestions]
          
          # Clear the session token
          session.delete(:analysis_token)
        end
      end
    end
  end

  private

  def extract_tags(game_data)
    tags = (game_data['genres'] || []).map { |g| g['description'] }
    tags += (game_data['categories'] || []).map { |c| c['description'] }
    tags.uniq
  end

  def generate_ai_suggestions(game_data)
    Rails.logger.debug "OpenAI API Key present: #{ENV['OPENAI_API_KEY'].present?}"
    ai = AiContentSuggester.new
    {
      short_description: ai.improve_short_description(game_data['short_description']),
      first_paragraph: ai.improve_first_paragraph(game_data['about_the_game']),
      feature_list: ai.suggest_feature_list(game_data['about_the_game'])
    }
  end
end
