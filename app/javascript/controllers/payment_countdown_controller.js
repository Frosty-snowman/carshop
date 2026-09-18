import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "bar"]
  static values = { deadline: String, expiredUrl: String }

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const remaining = new Date(this.deadlineValue) - Date.now()

    if (remaining <= 0) {
      this.displayTarget.textContent = "หมดเวลาแล้ว"
      if (this.hasBarTarget) this.barTarget.style.width = "0%"
      clearInterval(this.timer)
      setTimeout(() => {
        window.location.href = this.expiredUrlValue || window.location.href
      }, 1500)
      return
    }

    const minutes = Math.floor(remaining / 60000)
    const seconds = Math.floor((remaining % 60000) / 1000)
    this.displayTarget.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`

    if (this.hasBarTarget) {
      const total = 5 * 60 * 1000
      const pct = Math.max(0, (remaining / total) * 100)
      this.barTarget.style.width = `${pct}%`
      this.barTarget.classList.toggle("bg-red-500", remaining < 60000)
      this.barTarget.classList.toggle("bg-amber-400", remaining >= 60000 && remaining < 120000)
      this.barTarget.classList.toggle("bg-emerald-400", remaining >= 120000)
    }
  }
}
