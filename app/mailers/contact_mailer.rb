class ContactMailer < ApplicationMailer
  def new_submission(email:, game_name:, game_slug:, message:)
    @email = email
    @game_name = game_name
    @game_slug = game_slug
    @message = message
    @analysis_url = game_slug.present? ? show_analysis_url(game_slug: game_slug) : nil
    
    subject = game_name.present? ? "New Steam Page Review Request: #{game_name}" : "New Contact Form Submission"
    
    mail(
      to: "keyvan.games@pm.me",
      subject: subject,
      reply_to: @email
    )
  end
end 