class ContactSubmissionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    Rails.logger.info "Contact form submitted with params: #{params.inspect}"
    
    # Send email directly without storing in database
    mail = ContactMailer.new_submission(
      email: params[:email],
      game_name: params[:game_name],
      game_slug: params[:game_slug],
      message: params[:message]
    )
    
    # Log the email content to console
    Rails.logger.info "=== EMAIL CONTENT ==="
    Rails.logger.info "To: #{mail.to}"
    Rails.logger.info "Subject: #{mail.subject}"
    Rails.logger.info "Body: #{mail.body.encoded}"
    Rails.logger.info "===================="
    
    mail.deliver_now
    
    Rails.logger.info "Email sent successfully"
    
    respond_to do |format|
      format.html { 
        if params[:game_slug].present?
          redirect_to show_analysis_path(game_slug: params[:game_slug]), 
          notice: "Thank you! We'll get back to you soon." 
        else
          redirect_to contact_path, 
          notice: "Thank you! We'll get back to you soon." 
        end
      }
      format.json { render json: { status: 'success', message: 'Thank you! We\'ll get back to you soon.' } }
    end
  rescue => e
    Rails.logger.error "Failed to send contact email: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    respond_to do |format|
      format.html { 
        if params[:game_slug].present?
          redirect_to show_analysis_path(game_slug: params[:game_slug]), 
          alert: "There was an error sending your message. Please try again." 
        else
          redirect_to contact_path, 
          alert: "There was an error sending your message. Please try again." 
        end
      }
      format.json { render json: { status: 'error', message: 'There was an error. Please try again.' }, status: :unprocessable_entity }
    end
  end

  private

  def contact_submission_params
    params.require(:contact_submission).permit(:email, :game_name, :game_slug, :message)
  end
end 