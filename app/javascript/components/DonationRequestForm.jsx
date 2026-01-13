import React, { useState } from 'react'
import { createRoot } from 'react-dom/client'

const DONOR_TYPES = [
  { value: 'staff', label: 'TECA Staff' },
  { value: 'family', label: 'TECA Family' },
  { value: 'business_nonprofit', label: 'Business/Non-profit' }
]

function DonationRequestForm({ donors, events, csrfToken, formAction, selectedEventId, currentVolunteer }) {
  const [createNewDonor, setCreateNewDonor] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [errors, setErrors] = useState([])

  // Form state
  const [donorId, setDonorId] = useState('')
  const [eventId, setEventId] = useState(selectedEventId || events[0]?.id || '')
  const [volunteerId, setVolunteerId] = useState(currentVolunteer?.id?.toString() || '')
  const [notes, setNotes] = useState('')

  // New donor state
  const [newDonor, setNewDonor] = useState({
    name: '',
    donor_type: 'business_nonprofit',
    email_address: '',
    phone_number: '',
    website: '',
    primary_contact: '',
    relationship_to_teca: '',
    notes: ''
  })

  const handleNewDonorChange = (field, value) => {
    setNewDonor(prev => ({ ...prev, [field]: value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setIsSubmitting(true)
    setErrors([])

    const formData = new FormData()
    formData.append('authenticity_token', csrfToken)
    formData.append('donation_request[event_id]', eventId)
    formData.append('donation_request[notes]', notes)
    if (volunteerId) {
      formData.append('donation_request[volunteer_id]', volunteerId)
    }

    if (createNewDonor) {
      formData.append('create_new_donor', '1')
      Object.entries(newDonor).forEach(([key, value]) => {
        formData.append(`new_donor[${key}]`, value)
      })
    } else {
      formData.append('donation_request[donor_id]', donorId)
    }

    try {
      const response = await fetch(formAction, {
        method: 'POST',
        headers: {
          'Accept': 'text/html,application/xhtml+xml'
        },
        body: formData
      })

      if (response.redirected) {
        window.location.href = response.url
      } else if (!response.ok) {
        const html = await response.text()
        // Extract error messages if present
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, 'text/html')
        const errorList = doc.querySelectorAll('.text-red-700 li')
        if (errorList.length > 0) {
          setErrors(Array.from(errorList).map(li => li.textContent))
        } else {
          setErrors(['Something went wrong. Please try again.'])
        }
      }
    } catch (error) {
      setErrors(['Network error. Please try again.'])
    } finally {
      setIsSubmitting(false)
    }
  }

  const inputClasses = "block w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-sm px-3 py-2"
  const labelClasses = "text-sm font-medium text-gray-500"

  return (
    <form onSubmit={handleSubmit} className="divide-y divide-gray-100">
      {errors.length > 0 && (
        <div className="px-6 py-5">
          <div className="rounded-lg bg-red-50 p-4 border border-red-200">
            <h3 className="text-sm font-medium text-red-800">
              {errors.length === 1 ? '1 error' : `${errors.length} errors`} prohibited this donation request from being saved:
            </h3>
            <ul className="mt-2 list-disc list-inside text-sm text-red-700">
              {errors.map((error, i) => (
                <li key={i}>{error}</li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {/* Event Selection */}
      <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
        <label className={labelClasses}>Event</label>
        <div className="mt-1 sm:col-span-2 sm:mt-0">
          <select
            value={eventId}
            onChange={(e) => setEventId(e.target.value)}
            className={inputClasses}
            required
          >
            {events.map(event => (
              <option key={event.id} value={event.id}>{event.name}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Donor Toggle */}
      <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
        <label className={labelClasses}>Donor</label>
        <div className="mt-1 sm:col-span-2 sm:mt-0">
          <label className="inline-flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={createNewDonor}
              onChange={(e) => setCreateNewDonor(e.target.checked)}
              className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
            />
            <span className="text-sm text-gray-700">Create new donor</span>
          </label>
        </div>
      </div>

      {/* Existing Donor Dropdown */}
      {!createNewDonor && (
        <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
          <label className={labelClasses}>Select Donor</label>
          <div className="mt-1 sm:col-span-2 sm:mt-0">
            <select
              value={donorId}
              onChange={(e) => setDonorId(e.target.value)}
              className={inputClasses}
              required={!createNewDonor}
            >
              <option value="">Choose a donor</option>
              {donors.map(donor => (
                <option key={donor.id} value={donor.id}>{donor.name}</option>
              ))}
            </select>
          </div>
        </div>
      )}

      {/* New Donor Fields */}
      {createNewDonor && (
        <>
          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Donor Name *</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="text"
                value={newDonor.name}
                onChange={(e) => handleNewDonorChange('name', e.target.value)}
                className={inputClasses}
                required={createNewDonor}
                placeholder="Enter donor name"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Donor Type</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <select
                value={newDonor.donor_type}
                onChange={(e) => handleNewDonorChange('donor_type', e.target.value)}
                className={inputClasses}
              >
                {DONOR_TYPES.map(type => (
                  <option key={type.value} value={type.value}>{type.label}</option>
                ))}
              </select>
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Email</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="email"
                value={newDonor.email_address}
                onChange={(e) => handleNewDonorChange('email_address', e.target.value)}
                className={inputClasses}
                placeholder="email@example.com"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Phone</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="tel"
                value={newDonor.phone_number}
                onChange={(e) => handleNewDonorChange('phone_number', e.target.value)}
                className={inputClasses}
                placeholder="(555) 123-4567"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Website</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="url"
                value={newDonor.website}
                onChange={(e) => handleNewDonorChange('website', e.target.value)}
                className={inputClasses}
                placeholder="https://example.com"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Primary Contact</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="text"
                value={newDonor.primary_contact}
                onChange={(e) => handleNewDonorChange('primary_contact', e.target.value)}
                className={inputClasses}
                placeholder="Contact person name"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
            <label className={labelClasses}>Relationship to TECA</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <input
                type="text"
                value={newDonor.relationship_to_teca}
                onChange={(e) => handleNewDonorChange('relationship_to_teca', e.target.value)}
                className={inputClasses}
                placeholder="e.g., Parent of student, Local business"
              />
            </div>
          </div>

          <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4">
            <label className={labelClasses}>Donor Notes</label>
            <div className="mt-1 sm:col-span-2 sm:mt-0">
              <textarea
                value={newDonor.notes}
                onChange={(e) => handleNewDonorChange('notes', e.target.value)}
                rows={3}
                className={inputClasses}
                placeholder="Notes about the donor..."
              />
            </div>
          </div>
        </>
      )}

      {/* Assigned Volunteer */}
      <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:items-center">
        <label className={labelClasses}>Assigned To</label>
        <div className="mt-1 sm:col-span-2 sm:mt-0">
          <select
            value={volunteerId}
            onChange={(e) => setVolunteerId(e.target.value)}
            className={inputClasses}
          >
            <option value="">Unassigned (available to claim)</option>
            {currentVolunteer && (
              <option value={currentVolunteer.id}>
                {currentVolunteer.name || currentVolunteer.email} (me)
              </option>
            )}
          </select>
        </div>
      </div>

      {/* Request Notes */}
      <div className="px-6 py-5 sm:grid sm:grid-cols-3 sm:gap-4">
        <label className={labelClasses}>Request Notes</label>
        <div className="mt-1 sm:col-span-2 sm:mt-0">
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            rows={4}
            className={inputClasses}
            placeholder="Notes about this donation request"
          />
        </div>
      </div>

      {/* Submit */}
      <div className="px-6 py-5 flex items-center justify-end gap-3">
        <a
          href="/"
          className="rounded-lg px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-100 transition-colors"
        >
          Cancel
        </a>
        <button
          type="submit"
          disabled={isSubmitting}
          className="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Creating...' : 'Create Donation Request'}
        </button>
      </div>
    </form>
  )
}

// Mount function
function mountDonationRequestForm() {
  const container = document.querySelector('[data-donation-request-form]')
  if (!container || container.dataset.mounted) return

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  const donors = JSON.parse(container.dataset.donors || '[]')
  const events = JSON.parse(container.dataset.events || '[]')
  const formAction = container.dataset.formAction
  const selectedEventId = container.dataset.selectedEventId
  const currentVolunteer = JSON.parse(container.dataset.currentVolunteer || 'null')

  const root = createRoot(container)
  root.render(
    <DonationRequestForm
      donors={donors}
      events={events}
      csrfToken={csrfToken}
      formAction={formAction}
      selectedEventId={selectedEventId}
      currentVolunteer={currentVolunteer}
    />
  )

  container.dataset.mounted = 'true'
}

document.addEventListener('DOMContentLoaded', mountDonationRequestForm)
document.addEventListener('turbo:load', mountDonationRequestForm)

export { DonationRequestForm, mountDonationRequestForm }