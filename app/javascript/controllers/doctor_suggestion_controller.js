// Stimulus controller that handles the "Get Doctor Suggestion" button
import { Controller } from "@hotwired/stimulus"

export default class DoctorSuggestionController extends Controller {
  // Declare which elements we want to control from HTML
  static targets = ["button", "result"]

  async suggest() {
    // Get the health record ID from the outer <div>
    const recordId = this.element.dataset.recordId

    // Show loading message and disable button while fetching
    this.resultTarget.textContent = "⏳ Asking AI..."
    this.buttonTarget.disabled = true

    // Send a POST request to Rails at /records/:id/doctor_suggestion
    const response = await fetch(`/records/${recordId}/doctor_suggestion`, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      }
    })

    // Get the Gemini AI response from the server
    const data = await response.json()

    // Display Gemini's suggestion to the user
    this.resultTarget.textContent = data.suggestion
    this.buttonTarget.disabled = false
  }
}

