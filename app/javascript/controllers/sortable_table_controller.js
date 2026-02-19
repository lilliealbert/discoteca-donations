import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "body"]

  sort(event) {
    const header = event.currentTarget
    const columnIndex = Array.from(header.parentElement.children).indexOf(header)
    const currentDirection = header.dataset.sortDirection || "none"
    const newDirection = currentDirection === "asc" ? "desc" : "asc"

    // Reset all headers
    this.headerTargets.forEach(h => {
      h.dataset.sortDirection = "none"
      const icon = h.querySelector("[data-sort-icon]")
      if (icon) icon.setAttribute("class", "ml-1 h-4 w-4 text-gray-400 opacity-0 group-hover/header:opacity-100")
    })

    // Set current header
    header.dataset.sortDirection = newDirection
    const icon = header.querySelector("[data-sort-icon]")
    if (icon) {
      icon.setAttribute("class", "ml-1 h-4 w-4 text-gray-600")
      icon.innerHTML = newDirection === "asc"
        ? '<path stroke-linecap="round" stroke-linejoin="round" d="M4.5 15.75l7.5-7.5 7.5 7.5" />'
        : '<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />'
    }

    // Sort the rows
    const tbody = this.bodyTarget
    const rows = Array.from(tbody.querySelectorAll("tr"))

    rows.sort((a, b) => {
      const aCell = a.cells[columnIndex]
      const bCell = b.cells[columnIndex]

      if (!aCell || !bCell) return 0

      let aValue = this.getCellValue(aCell)
      let bValue = this.getCellValue(bCell)

      // Try to parse as numbers
      const aNum = parseFloat(aValue.replace(/[^0-9.-]/g, ""))
      const bNum = parseFloat(bValue.replace(/[^0-9.-]/g, ""))

      if (!isNaN(aNum) && !isNaN(bNum)) {
        return newDirection === "asc" ? aNum - bNum : bNum - aNum
      }

      // Try to parse as dates
      const aDate = Date.parse(aValue)
      const bDate = Date.parse(bValue)

      if (!isNaN(aDate) && !isNaN(bDate)) {
        return newDirection === "asc" ? aDate - bDate : bDate - aDate
      }

      // String comparison
      return newDirection === "asc"
        ? aValue.localeCompare(bValue)
        : bValue.localeCompare(aValue)
    })

    // Re-append sorted rows
    rows.forEach(row => tbody.appendChild(row))
  }

  getCellValue(cell) {
    // Check for data-sort-value attribute first
    if (cell.dataset.sortValue) {
      return cell.dataset.sortValue
    }
    // Get text content, trimmed
    return cell.textContent.trim()
  }
}