import React, { useState } from 'react'
import { createRoot } from 'react-dom/client'

const STATUS_OPTIONS = [
  { value: 'unasked', label: 'Unasked' },
  { value: 'asked_once', label: 'Asked once' },
  { value: 'asked_twice', label: 'Asked twice' },
  { value: 'asked_thrice', label: 'Asked thrice' },
  { value: 'no', label: 'No' },
  { value: 'yes', label: 'Yes' }
]

const STATUS_CLASSES = {
  unasked: 'bg-gray-50 text-gray-600 ring-gray-500/10',
  asked_once: 'bg-blue-50 text-blue-700 ring-blue-600/20',
  asked_twice: 'bg-yellow-50 text-yellow-700 ring-yellow-600/20',
  asked_thrice: 'bg-orange-50 text-orange-700 ring-orange-600/20',
  no: 'bg-red-50 text-red-700 ring-red-600/20',
  yes: 'bg-green-50 text-green-700 ring-green-600/20'
}

function StatusEditor({ requestId, initialStatus, csrfToken }) {
  const [status, setStatus] = useState(initialStatus)
  const [isEditing, setIsEditing] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const statusLabel = STATUS_OPTIONS.find(s => s.value === status)?.label || 'Unknown'
  const statusClasses = STATUS_CLASSES[status] || STATUS_CLASSES.unasked

  const handleStatusChange = async (newStatus) => {
    setIsLoading(true)
    try {
      const response = await fetch(`/donation_requests/${requestId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ donation_request: { request_status: newStatus } })
      })

      if (response.ok) {
        setStatus(newStatus)
        setIsEditing(false)
      } else {
        alert('Failed to update status')
      }
    } catch (error) {
      alert('Failed to update status')
    } finally {
      setIsLoading(false)
    }
  }

  if (isEditing) {
    return (
      <div className="flex items-center gap-2">
        <select
          value={status}
          onChange={(e) => handleStatusChange(e.target.value)}
          disabled={isLoading}
          className="text-xs border-gray-300 rounded focus:border-indigo-500 focus:ring-indigo-500"
          autoFocus
        >
          {STATUS_OPTIONS.map(option => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        <button
          onClick={() => setIsEditing(false)}
          className="text-gray-400 hover:text-gray-600"
          disabled={isLoading}
        >
          <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    )
  }

  return (
    <div className="flex items-center gap-2">
      <span className={`inline-flex items-center rounded-full px-2 py-1 text-xs font-medium ring-1 ring-inset ${statusClasses}`}>
        {statusLabel}
      </span>
      <button
        onClick={() => setIsEditing(true)}
        className="text-gray-400 hover:text-indigo-600 transition-colors"
      >
        <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
          <path strokeLinecap="round" strokeLinejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
        </svg>
      </button>
    </div>
  )
}

// Mount all StatusEditor components on the page
document.addEventListener('DOMContentLoaded', () => {
  mountStatusEditors()
})

// Also mount on Turbo navigation
document.addEventListener('turbo:load', () => {
  mountStatusEditors()
})

function mountStatusEditors() {
  const containers = document.querySelectorAll('[data-status-editor]')
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

  containers.forEach(container => {
    // Skip if already mounted
    if (container.dataset.mounted) return

    const requestId = container.dataset.requestId
    const initialStatus = container.dataset.initialStatus

    const root = createRoot(container)
    root.render(
      <StatusEditor
        requestId={requestId}
        initialStatus={initialStatus}
        csrfToken={csrfToken}
      />
    )

    container.dataset.mounted = 'true'
  })
}

export { StatusEditor, mountStatusEditors }