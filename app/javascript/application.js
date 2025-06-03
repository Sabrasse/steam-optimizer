// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import { application } from "controllers/application"
import AnalysisController from "controllers/analysis_controller"
import FormController from "controllers/form_controller"
import FeedbackController from "controllers/feedback_controller"

// Register all controllers
application.register("analysis", AnalysisController)
application.register("form", FormController)
application.register("feedback", FeedbackController)

console.log("✅ JS loaded: application.js")

// This is a test