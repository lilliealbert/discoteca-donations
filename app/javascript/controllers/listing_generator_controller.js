import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "shortDescription", "longDescription", "loading", "error", "generateButton"]
  static values = {
    url: String,
    autoGenerate: { type: Boolean, default: true }
  }

  connect() {
    if (this.autoGenerateValue && this.shouldAutoGenerate()) {
      this.generate()
    }
  }

  shouldAutoGenerate() {
    return !this.titleTarget.value &&
           !this.shortDescriptionTarget.value &&
           !this.longDescriptionTarget.value
  }

  async generate(event) {
    if (event) event.preventDefault()

    this.showLoading()
    this.hideError()

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.populateFields(data)
      } else {
        const error = await response.json()
        this.showError(error.error || "Failed to generate descriptions")
      }
    } catch (error) {
      this.showError("Network error. Please try again.")
    } finally {
      this.hideLoading()
    }
  }

  populateFields(data) {
    if (data.title) this.titleTarget.value = data.title
    if (data.short_description) this.shortDescriptionTarget.value = data.short_description
    if (data.long_description) this.longDescriptionTarget.value = data.long_description
  }

  showLoading() {
    this.loadingTargets.forEach(el => el.classList.remove("hidden"))
    if (this.hasGenerateButtonTarget) {
      this.generateButtonTarget.disabled = true
      this.generateButtonTarget.textContent = "Generating..."
    }
  }

  hideLoading() {
    this.loadingTargets.forEach(el => el.classList.add("hidden"))
    if (this.hasGenerateButtonTarget) {
      this.generateButtonTarget.disabled = false
      this.generateButtonTarget.textContent = "Regenerate"
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove("hidden")
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
