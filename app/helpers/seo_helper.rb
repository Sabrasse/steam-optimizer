module SeoHelper
  def page_title(title = nil)
    base_title = "Steam Page Optimizer"
    if title.present?
      "#{title} | #{base_title}"
    else
      "#{base_title} - Analyze & Improve Your Steam Store Page Performance"
    end
  end

  def page_description(description = nil)
    description.presence || "Free Steam store page analyzer tool. Get AI-powered insights and optimization suggestions for your game's Steam page. Improve visibility, conversions, and sales."
  end

  def page_keywords(keywords = nil)
    base_keywords = "Steam, game marketing, store page optimization, Steam analytics, game development, indie games, Steam visibility, game promotion"
    if keywords.present?
      "#{keywords}, #{base_keywords}"
    else
      base_keywords
    end
  end

  def canonical_url(path = nil)
    if path.present?
      "#{request.base_url}#{path}"
    else
      request.original_url
    end
  end

  def og_image_url(image_url = nil)
    if image_url.present?
      image_url
    else
      "#{request.base_url}/og-image.jpg"
    end
  end

  def generate_structured_data(type, data = {})
    base_data = {
      "@context" => "https://schema.org"
    }
    
    case type
    when :website
      base_data.merge({
        "@type" => "WebSite",
        "name" => "Steam Page Optimizer",
        "url" => request.base_url,
        "description" => "Free Steam store page analyzer tool",
        "potentialAction" => {
          "@type" => "SearchAction",
          "target" => "#{request.base_url}/?app_id={search_term_string}",
          "query-input" => "required name=search_term_string"
        }
      })
    when :organization
      base_data.merge({
        "@type" => "Organization",
        "name" => "Steam Page Optimizer",
        "url" => request.base_url,
        "description" => "Tools and insights for Steam game developers"
      })
    when :video_game
      base_data.merge({
        "@type" => "VideoGame",
        "name" => data[:name],
        "description" => data[:description],
        "image" => data[:image],
        "url" => data[:url],
        "gamePlatform" => "Steam",
        "applicationCategory" => "Game"
      })
    else
      base_data.merge(data)
    end
  end

  def breadcrumb_schema(items)
    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.map.with_index do |item, index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => item[:name],
          "item" => item[:url]
        }
      end
    }
  end

  def set_meta_tags(options = {})
    content_for :head do
      tags = []
      
      # Title
      if options[:title]
        tags << content_tag(:title, page_title(options[:title]))
      end
      
      # Meta description
      if options[:description]
        tags << tag(:meta, name: "description", content: page_description(options[:description]))
      end
      
      # Keywords
      if options[:keywords]
        tags << tag(:meta, name: "keywords", content: page_keywords(options[:keywords]))
      end
      
      # Canonical URL
      if options[:canonical]
        tags << tag(:link, rel: "canonical", href: canonical_url(options[:canonical]))
      end
      
      # Open Graph tags
      if options[:og]
        og_data = options[:og]
        tags << tag(:meta, property: "og:title", content: og_data[:title] || page_title(options[:title]))
        tags << tag(:meta, property: "og:description", content: og_data[:description] || page_description(options[:description]))
        tags << tag(:meta, property: "og:image", content: og_image_url(og_data[:image]))
        tags << tag(:meta, property: "og:url", content: canonical_url(options[:canonical]))
        tags << tag(:meta, property: "og:type", content: og_data[:type] || "website")
      end
      
      # Twitter Cards
      if options[:twitter]
        twitter_data = options[:twitter]
        tags << tag(:meta, name: "twitter:card", content: twitter_data[:card] || "summary_large_image")
        tags << tag(:meta, name: "twitter:title", content: twitter_data[:title] || page_title(options[:title]))
        tags << tag(:meta, name: "twitter:description", content: twitter_data[:description] || page_description(options[:description]))
        tags << tag(:meta, name: "twitter:image", content: og_image_url(twitter_data[:image]))
      end
      
      # Structured data
      if options[:structured_data]
        tags << content_tag(:script, 
          options[:structured_data].to_json.html_safe, 
          type: "application/ld+json"
        )
      end
      
      tags.join("\n").html_safe
    end
  end
end 