class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :show_analysis]

  def home
    # Fetch the latest 3 completed analyses for the homepage display
    @latest_analyses = Analysis.joins(:game)
                              .where(status: 'completed')
                              .order(created_at: :desc)
                              .limit(3)
                              .includes(:game)
    
    if request.post?
      Rails.logger.debug "Form submitted with params: #{params.inspect}"
      
      # Retrieve the App ID from form input (it may be an ID or a full URL)
      input = params[:app_id].to_s.strip
      Rails.logger.debug "Input received: #{input}"
      
      if input.blank?
        @error_message = "Please enter a Steam App ID or URL."
        return
      end

      # Use the SteamApiClient service to fetch game data from Steam
      app_id = SteamApiClient.extract_app_id(input)
      Rails.logger.debug "Extracted App ID: #{app_id}"
      
      # Find or create the game
      @game = Game.find_or_initialize_by(steam_app_id: app_id)
      
      if @game.new_record?
        # Fetch game data from Steam
        game_data = SteamApiClient.fetch_game_data(app_id)
        Rails.logger.debug "Game data fetched: #{game_data.present?}"

        if game_data.nil?
          @error_message = "Could not retrieve data for App ID #{app_id}. Please check the ID and try again."
          return
        end

        # Set game attributes
        @game.name = game_data['name']
        @game.short_description = game_data['short_description']
        @game.about_the_game = strip_images_from_content(game_data['about_the_game'])
        @game.capsule_image_url = game_data['capsule_image_url']
        @game.genres = game_data['genres']
        @game.categories = game_data['categories']
        @game.screenshots = game_data['screenshots']
        @game.movies = game_data['movies']
        
        # Save the game
        unless @game.save
          @error_message = "Error saving game data."
          return
        end
      end

      # Check if game already has an analysis
      if @game.analyses.latest.present?
        redirect_to show_analysis_path(game_slug: @game.slug), notice: "Analysis already exists."
        return
      end

      # Create new analysis
      @analysis = @game.analyses.build
      
      # Process the game data
      begin
        @analysis.mark_as_processing!
        
        # Text analysis
        @analysis.text_report = TextAnalyzer.new(@game).analyze
        
        # Visual analysis
        @analysis.visual_report = VisualAnalyzer.new(@game).analyze
        
        # Tags analysis
        @analysis.tags_list = extract_tags(@game)
        @tags_score, @tags_feedback = TextAnalyzer.grade_tags(@analysis.tags_list)
        
        # AI suggestions
        @analysis.ai_suggestions = generate_ai_suggestions(@game)
        
        # Image analysis
        if @game.capsule_image_url.present?
          image_suggester = AiImageSuggester.new
          @analysis.image_suggestions = image_suggester.suggest_capsule_image_improvements(@game.capsule_image_url)
          @analysis.image_validation = image_suggester.validate_capsule_image(@game.capsule_image_url)
        end

        @analysis.mark_as_completed!
        redirect_to show_analysis_path(game_slug: @game.slug), notice: "Analysis completed successfully!"
      rescue StandardError => e
        Rails.logger.error "Analysis failed: #{e.message}"
        @analysis.mark_as_failed!
        @error_message = "Analysis failed. Please try again."
      end
    end
  end

  def show_analysis
    @game = Game.find_by!(slug: params[:game_slug])
    
    # If an analysis ID is provided, use that specific analysis
    # Otherwise, use the latest analysis
    @analysis = if params[:id]
      @game.analyses.find_by!(id: params[:id])
    else
      @game.analyses.latest
    end

    respond_to do |format|
      format.html
      format.json { render json: { status: @analysis.status } }
    end
  end

  private

  def extract_tags(game)
    tags = (game.genres || []).map { |g| g['description'] }
    tags += (game.categories || []).map { |c| c['description'] }
    tags.uniq
  end

  def generate_ai_suggestions(game)
    Rails.logger.debug "OpenAI API Key present: #{ENV['OPENAI_API_KEY'].present?}"
    ai = AiContentSuggester.new
    {
      short_description: ai.improve_short_description(game.short_description),
      first_paragraph: ai.improve_first_paragraph(game.about_the_game),
      feature_list: ai.suggest_feature_list(game.about_the_game)
    }
  end

  def strip_images_from_content(content)
    return content unless content.present?
    
    # Use Nokogiri to parse and remove img tags
    doc = Nokogiri::HTML::DocumentFragment.parse(content)
    doc.css('img').remove
    doc.to_html
  end
end
