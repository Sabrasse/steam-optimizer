module ApplicationHelper
  # Strips img tags from HTML content to prevent layout issues
  def strip_images(html_content)
    return html_content unless html_content.present?
    
    # Use Nokogiri to parse and remove img tags
    doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
    doc.css('img').remove
    doc.to_html.html_safe
  end
end
