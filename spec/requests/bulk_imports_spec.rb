require 'rails_helper'
require 'csv'

RSpec.describe "BulkImports", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:volunteer) { Volunteer.create!(email: "test@example.com", password: "password123") }
  let(:event) { Event.create!(name: "Test Auction", date: Date.tomorrow) }
  let(:file) { Tempfile.new(['import', '.csv']) }

  before do
    sign_in volunteer, scope: :volunteer

    CSV.open(file.path, 'w') do |csv|
      csv << ["Name", "Primary Contact", "Email", "Phone", "Website", "Relationship to TECA", "Donor Notes", "Donor Type", "Donation Notes"]
      csv << ["Test Donor", "John Smith", "john@example.com", "415-111-1111", "https://example.com", "2nd grade parent", "Great donor", "family", "Wine basket"]
    end
    file.rewind
  end

  after do
    file.close
    file.unlink
  end

  describe "POST /bulk_imports" do
    it "creates donation requests from CSV" do
      expect {
        post bulk_imports_path, params: {
          event_id: event.id,
          note_prefix: "2025: ",
          file: Rack::Test::UploadedFile.new(file.path, 'text/csv')
        }
      }.to change(DonationRequest, :count).by(1)
       .and change(Donor, :count).by(1)

      expect(response).to redirect_to(event_path(event))
      follow_redirect!
      expect(response.body).to include("Donation requests imported successfully")

      donor = Donor.last
      expect(donor.name).to eq("Test Donor")
      expect(donor.primary_contact).to eq("John Smith")
      expect(donor.email_address).to eq("john@example.com")

      donation_request = DonationRequest.last
      expect(donation_request.notes).to eq("2025: Wine basket")
      expect(donation_request.event).to eq(event)
    end

    it "redirects with alert when no file provided" do
      post bulk_imports_path, params: { event_id: event.id }

      expect(response).to redirect_to(new_bulk_import_path)
      follow_redirect!
      expect(response.body).to include("Please select a CSV file")
    end
  end
end