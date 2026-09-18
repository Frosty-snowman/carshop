import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "image", "filename", "placeholder", "saveHint"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) return

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = file.name
    }
    if (this.hasSaveHintTarget) {
      this.saveHintTarget.classList.remove("hidden")
    }
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add("hidden")
    }

    if (file.type.startsWith("image/")) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.classList.remove("hidden")
        this.imageTarget.src = e.target.result
      }
      reader.readAsDataURL(file)
    } else {
      this.previewTarget.classList.remove("hidden")
      this.imageTarget.classList.add("hidden")
    }
  }
}
