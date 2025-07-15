class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :show_analysis, :submit_feedback, :games_index, :contact]

  def home
    # Fetch the latest 3 completed analyses for the homepage display
    @latest_analyses = Analysis.joins(:game)
                              .order(created_at: :desc)
                              .limit(3)
                              .includes(:game)
    
    if request.post?
      
      # Retrieve the App ID from form input (it may be an ID or a full URL)
      input = params[:app_id].to_s.strip
      
      if input.blank?
        @error_message = "Please enter a Steam App ID or URL."
        return
      end

      # Use the SteamApiClient service to fetch game data from Steam
      app_id = SteamApiClient.extract_app_id(input)
      
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
      if @game.analyses.exists?
        redirect_to show_analysis_path(game_slug: @game.slug), notice: "Analysis already exists."
        return
      end

      # Create new analysis
      @analysis = @game.analyses.build
      
      # Process the game data
      begin
        # Tags analysis
        @analysis.tags_list = extract_tags(@game)
        
        # AI suggestions
        @analysis.ai_suggestions = generate_ai_suggestions(@game)
        
        # Image analysis
        if @game.capsule_image_url.present?
          image_suggester = AiImageSuggester.new
          @analysis.image_suggestions = image_suggester.suggest_capsule_image_improvements(@game.capsule_image_url)
        end

        @analysis.save!
        redirect_to show_analysis_path(game_slug: @game.slug), notice: "Analysis completed successfully!"
      rescue StandardError => e
        Rails.logger.error "Analysis failed: #{e.message}"
        @error_message = "Analysis failed. Please try again."
      end
    end
  end

  def games_index
    @analyses = Analysis.joins(:game)
                       .order(created_at: :desc)
                       .includes(:game)
                       .page(params[:page])
                       .per(12) # Show 12 games per page
  end

  def contact
    # Contact page action - no additional logic needed for now
  end

  def show_analysis
    @game = Game.find_by(slug: params[:game_slug])
    
    if @game.nil?
      redirect_to root_path, alert: "Game not found. Please check the URL and try again."
      return
    end
    
    Rails.logger.debug "Found game: #{@game.inspect}"
    
    # If an analysis ID is provided, use that specific analysis
    # Otherwise, use the latest analysis
    @analysis = if params[:id]
      @game.analyses.find_by!(id: params[:id])
    else
      @game.analyses.latest
    end
    Rails.logger.debug "Found analysis: #{@analysis.inspect}"

    respond_to do |format|
      format.html
      format.json { render json: { status: @analysis.status } }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Analysis not found. Please check the URL and try again."
  end

  def submit_feedback
    @analysis = Analysis.find(params[:analysis_id])
    Rails.logger.debug "Found analysis: #{@analysis.inspect}"
    Rails.logger.debug "Feedback params: #{params.inspect}"
    
    # Update the feedback fields
    update_params = {}
    update_params["user_rating_#{params[:section]}"] = params[:rating] if params[:rating].present?
    update_params["user_feedback_#{params[:section]}"] = params[:feedback] if params[:feedback].present?

    if @analysis.update(update_params)
      respond_to do |format|
        format.html { redirect_to show_analysis_path(game_slug: @analysis.game.slug), notice: "Thank you for your feedback!" }
        format.json { render json: { status: 'success' } }
      end
    else
      Rails.logger.error "Failed to update analysis: #{@analysis.errors.full_messages.join(', ')}"
      respond_to do |format|
        format.html { redirect_to show_analysis_path(game_slug: @analysis.game.slug), alert: "Could not save feedback: #{@analysis.errors.full_messages.join(', ')}" }
        format.json { render json: { status: 'error', message: @analysis.errors.full_messages.join(', ') }, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Analysis not found" }
      format.json { render json: { status: 'error', message: 'Analysis not found' }, status: :not_found }
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
    tag_suggester = AiTagSuggester.new
    
    {
      short_description: ai.improve_short_description(game.short_description),
      tags: tag_suggester.suggest_tags(game)
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
