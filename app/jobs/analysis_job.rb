class AnalysisJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    @game = Game.find(game_id)
    @analysis = @game.analyses.latest

    Rails.logger.info "Starting analysis for game: #{@game.name} (ID: #{@game.id})"
    
    begin
      # Initialize reports
      @text_report = { score: 'F', issues: [] }
      @visual_report = { score: 'F', issues: [] }
      @tags_list = []

      # Analyze text content
      analyze_text_content
      
      # Analyze visuals
      analyze_visuals
      
      # Analyze tags
      analyze_tags

      # Save the analysis - no need to convert to JSON since the columns are jsonb
      @analysis.update!(
        text_report: @text_report,
        visual_report: @visual_report,
        tags_list: @tags_list,
        status: :completed
      )

      Rails.logger.info "Analysis completed successfully for game: #{@game.name}"
    rescue StandardError => e
      Rails.logger.error "Analysis failed for game #{@game.name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @analysis.mark_as_failed!
      raise e
    end
  end

  private

  def analyze_text_content
    Rails.logger.info "Analyzing text content for game: #{@game.name}"
    
    begin
      # Check description
      if @game.short_description.present?
        @text_report[:score] = 'A'
        @text_report[:issues] << "Description is present and well-formatted"
      else
        @text_report[:score] = 'F'
        @text_report[:issues] << "Missing short description"
      end

      # Check about section
      if @game.about_the_game.present?
        if @game.about_the_game.length < 100
          @text_report[:score] = 'D'
          @text_report[:issues] << "About section is too short (less than 100 characters)"
        elsif @game.about_the_game.length > 2000
          @text_report[:score] = 'C'
          @text_report[:issues] << "About section is too long (more than 2000 characters)"
        else
          @text_report[:issues] << "About section length is appropriate"
        end
      else
        @text_report[:score] = 'F'
        @text_report[:issues] << "Missing about section"
      end

      Rails.logger.info "Text analysis completed. Score: #{@text_report[:score]}"
    rescue StandardError => e
      Rails.logger.error "Error in text analysis: #{e.message}"
      raise e
    end
  end

  def analyze_visuals
    Rails.logger.info "Analyzing visuals for game: #{@game.name}"
    
    begin
      # Check screenshots
      screenshots = @game.screenshots.present? ? @game.screenshots : []
      if screenshots.size < 5
        @visual_report[:score] = 'D'
        @visual_report[:issues] << "Not enough screenshots (only #{screenshots.size}, recommend at least 5)"
      else
        @visual_report[:issues] << "Good number of screenshots (#{screenshots.size})"
      end

      # Check trailers
      trailers = @game.movies.present? ? @game.movies : []
      if trailers.empty?
        @visual_report[:score] = 'C'
        @visual_report[:issues] << "No trailers uploaded"
      else
        @visual_report[:issues] << "Trailers present (#{trailers.size})"
      end

      # Check capsule image
      if @game.capsule_image_url.present?
        @visual_report[:issues] << "Capsule image present"
      else
        @visual_report[:score] = 'F'
        @visual_report[:issues] << "Missing capsule image"
      end

      # Update score if no critical issues
      if @visual_report[:score] == 'F' && @visual_report[:issues].none? { |i| i.include?('Missing') }
        @visual_report[:score] = 'B'
      end

      Rails.logger.info "Visual analysis completed. Score: #{@visual_report[:score]}"
    rescue StandardError => e
      Rails.logger.error "Error in visual analysis: #{e.message}"
      raise e
    end
  end

  def analyze_tags
    Rails.logger.info "Analyzing tags for game: #{@game.name}"
    
    begin
      # Get tags from Steam API
      tags = @game.steam_tags.present? ? @game.steam_tags : []
      @tags_list = tags.map { |t| t['name'] }

      Rails.logger.info "Tags analysis completed. Found #{@tags_list.size} tags"
    rescue StandardError => e
      Rails.logger.error "Error in tags analysis: #{e.message}"
      raise e
    end
  end
end 