import { Controller } from "@hotwired/stimulus"

// Toggles dark/light theme. Persists in localStorage; defaults to system preference.
// Apply theme to <html> so Tailwind dark: variants take effect.
export default class extends Controller {
  connect() {
    this.applyStoredOrSystem()
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    this.setTheme(isDark ? "light" : "dark")
  }

  applyStoredOrSystem() {
    const stored = localStorage.getItem("billi-theme")
    if (stored === "dark" || stored === "light") {
      this.setTheme(stored, false)
      return
    }
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    this.setTheme(prefersDark ? "dark" : "light", false)
  }

  setTheme(mode, persist = true) {
    const root = document.documentElement
    if (mode === "dark") {
      root.classList.add("dark")
    } else {
      root.classList.remove("dark")
    }
    if (persist) {
      try {
        localStorage.setItem("billi-theme", mode)
      } catch (_) {}
    }
  }
}
