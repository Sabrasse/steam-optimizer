class ContactMailer < ApplicationMailer
  def new_submission(email:, game_name:, game_slug:, message:)
    @email = email
    @game_name = game_name
    @game_slug = game_slug
    @message = message
    @analysis_url = show_analysis_url(game_slug: game_slug)
    
    mail(
      to: "keyvan.games@pm.me",
      subject: "New Steam Page Review Request: #{game_name}",
      reply_to: @email
    )
  end
end 