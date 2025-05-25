namespace :seo do
  desc "Generate sitemap including all completed game analyses"
  task generate_sitemap: :environment do
    puts "Generating sitemap..."
    SitemapGenerator.generate
    puts "Sitemap generated successfully at public/sitemap.xml"
  end

  desc "Update all meta tags and SEO data"
  task update_meta_data: :environment do
    puts "Updating SEO meta data..."
    
    # Update any missing slugs for games
    Game.where(slug: [nil, ""]).find_each do |game|
      game.update(slug: game.name.parameterize) if game.name.present?
    end
    
    puts "SEO meta data updated successfully"
  end

  desc "Run all SEO maintenance tasks"
  task maintenance: [:update_meta_data, :generate_sitemap] do
    puts "All SEO maintenance tasks completed"
  end

  desc "Validate SEO setup"
  task validate: :environment do
    puts "Validating SEO setup..."
    
    errors = []
    
    # Check for missing Open Graph image
    og_image_path = Rails.root.join('public', 'og-image.jpg')
    errors << "Missing Open Graph image at public/og-image.jpg" unless File.exist?(og_image_path)
    
    # Check for missing favicon files
    favicon_files = ['favicon.ico', 'favicon-16x16.png', 'favicon-32x32.png', 'apple-touch-icon.png']
    favicon_files.each do |file|
      file_path = Rails.root.join('public', file)
      errors << "Missing favicon file: #{file}" unless File.exist?(file_path)
    end
    
    # Check for games without slugs
    games_without_slugs = Game.where(slug: [nil, ""]).count
    errors << "#{games_without_slugs} games missing slugs" if games_without_slugs > 0
    
    if errors.any?
      puts "SEO validation errors found:"
      errors.each { |error| puts "  - #{error}" }
      exit 1
    else
      puts "SEO setup validation passed!"
    end
  end
end 