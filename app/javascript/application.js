// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import { application } from "controllers/application"
import AnalysisController from "controllers/analysis_controller"

application.register("analysis", AnalysisController)

console.log("✅ JS loaded: application.js")

// This is a test