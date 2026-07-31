import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle(event) {
    if (event) event.preventDefault()
    const isExpanded = this.contentTarget.classList.toggle("expanded")
    const expandBtn = this.element.querySelector('.tree-expand')
    if (expandBtn) {
      expandBtn.textContent = isExpanded ? '[-]' : '[+]'
    }
  }
}