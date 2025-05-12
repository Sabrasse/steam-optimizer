import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["imageUrl", "results"]

  connect() {
    console.log("Image analysis controller connected")
  }

  analyze() {
    const imageUrl = this.imageUrlTarget.value
    if (!imageUrl) return

    // Show loading state
    this.resultsTarget.innerHTML = '<div class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>'

    // Make the request
    fetch(`/steam_images/analyze?game_id=${this.element.dataset.gameId}&image_url=${encodeURIComponent(imageUrl)}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error("Error analyzing image:", error)
      this.resultsTarget.innerHTML = '<div class="alert alert-danger">Error analyzing image. Please try again.</div>'
    })
  }
} 