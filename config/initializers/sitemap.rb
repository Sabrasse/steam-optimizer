# Sitemap configuration for SEO
# This can be used to generate dynamic sitemaps including game analysis pages

class SitemapGenerator
  def self.generate
    # Set default host for URL generation
    Rails.application.routes.default_url_options[:host] = ENV.fetch('HOST', 'localhost:3000')
    
    sitemap_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        <!-- Static pages -->
        <url>
          <loc>#{Rails.application.routes.url_helpers.root_url}</loc>
          <lastmod>#{Date.current}</lastmod>
          <changefreq>weekly</changefreq>
          <priority>1.0</priority>
        </url>
    XML

    # Add dynamic game analysis pages
    Game.joins(:analyses)
        .where(analyses: { status: 'completed' })
        .find_each do |game|
      sitemap_content += <<~XML
        <url>
          <loc>#{Rails.application.routes.url_helpers.show_analysis_url(game_slug: game.slug)}</loc>
          <lastmod>#{game.updated_at.to_date}</lastmod>
          <changefreq>monthly</changefreq>
          <priority>0.8</priority>
        </url>
      XML
    end

    sitemap_content += "\n</urlset>"
    
    # Write to public directory
    File.write(Rails.root.join('public', 'sitemap.xml'), sitemap_content)
    
    completed_games_count = Game.joins(:analyses).where(analyses: { status: 'completed' }).count
    Rails.logger.info "Sitemap generated with #{completed_games_count + 1} URLs"
    
    puts "Generated sitemap with #{completed_games_count + 1} URLs"
  end
end

# Uncomment the following line to generate sitemap on app startup (not recommended for production)
# SitemapGenerator.generate if Rails.env.development? 