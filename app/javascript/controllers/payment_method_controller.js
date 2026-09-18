import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bankPanel", "qrPanel"]

  connect() {
    this.toggle()
  }

  toggle(event) {
    const selected = event?.target?.value || this.element.querySelector('input[name="checkout[payment_method]"]:checked')?.value
    const bank = selected === "bank_transfer"
    const qr = selected === "qr"

    if (this.hasBankPanelTarget) {
      this.bankPanelTarget.classList.toggle("hidden", !bank)
    }
    if (this.hasQrPanelTarget) {
      this.qrPanelTarget.classList.toggle("hidden", !qr)
    }
  }
}
