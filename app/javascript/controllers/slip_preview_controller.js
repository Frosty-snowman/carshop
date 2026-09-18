import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "image", "pdfNotice", "filename", "placeholder"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) {
      this.clearPreview()
      return
    }

    this.previewTarget.classList.remove("hidden")
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add("hidden")
    }
    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = file.name
    }

    if (file.type.startsWith("image/")) {
      this.imageTarget.classList.remove("hidden")
      if (this.hasPdfNoticeTarget) this.pdfNoticeTarget.classList.add("hidden")

      const reader = new FileReader()
      reader.onload = (e) => {
        this.imageTarget.src = e.target.result
      }
      reader.readAsDataURL(file)
    } else {
      this.imageTarget.classList.add("hidden")
      this.imageTarget.removeAttribute("src")
      if (this.hasPdfNoticeTarget) this.pdfNoticeTarget.classList.remove("hidden")
    }
  }

  clearPreview() {
    this.previewTarget.classList.add("hidden")
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove("hidden")
    }
    this.imageTarget.classList.add("hidden")
    this.imageTarget.removeAttribute("src")
    if (this.hasPdfNoticeTarget) this.pdfNoticeTarget.classList.add("hidden")
  }

  disconnect() {
    if (this.imageTarget.src?.startsWith("blob:")) {
      URL.revokeObjectURL(this.imageTarget.src)
    }
  }
}
