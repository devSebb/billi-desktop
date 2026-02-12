import { Controller } from "@hotwired/stimulus"

// Simple mobile menu toggle for landing page.
// Usage:
//   <div data-controller="mobile-menu">
//     <button data-action="mobile-menu#toggle">Menu</button>
//     <div data-mobile-menu-target="panel" class="hidden">...</div>
//   </div>
export default class extends Controller {
  static targets = ["panel", "openIcon", "closeIcon"]

  toggle() {
    const panel = this.panelTarget
    const isOpen = !panel.classList.contains("hidden")

    if (isOpen) {
      panel.classList.add("hidden")
      document.body.style.overflow = ""
      if (this.hasOpenIconTarget) this.openIconTarget.classList.remove("hidden")
      if (this.hasCloseIconTarget) this.closeIconTarget.classList.add("hidden")
    } else {
      panel.classList.remove("hidden")
      document.body.style.overflow = "hidden"
      if (this.hasOpenIconTarget) this.openIconTarget.classList.add("hidden")
      if (this.hasCloseIconTarget) this.closeIconTarget.classList.remove("hidden")
    }
  }

  // Close menu when clicking a nav link
  close() {
    this.panelTarget.classList.add("hidden")
    document.body.style.overflow = ""
    if (this.hasOpenIconTarget) this.openIconTarget.classList.remove("hidden")
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.add("hidden")
  }
}
