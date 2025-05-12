# config/initializers/openai.rb
require 'ruby/openai'

OpenAI.configure do |config|
  config.access_token = ENV["OPENAI_API_KEY"]
end 