require 'rails_helper'
require 'csv'

describe BulkDonationRequestImport do
  let(:file) { Tempfile.new(['import', '.csv']) }

  before do
    CSV.open(file.path, 'w') do |csv|
      csv << ["Name", "Primary Contact", "Email", "Phone", "Website", "Relationship to TECA", "Donor Notes", "Type", "Donation Notes", "Volunteer"]
      csv << ["Acrosports", nil, "info@acrosports.org", nil, nil, nil, nil, "Business/Non-profit", "Acro fun night $50 value", nil]
      csv << ["Abada Capoeira", "Tamara McDonald - office manager", "info@abada.org", nil, nil, nil, nil, "staff", "Two sets of 4 classes", "beep@boop.bop"]
      csv << ["Zed (Zombie)", nil, "zed@example.com", nil, nil, nil, nil, "staff", "Two sets of 4 classes", "beep@boop.bop"]
    end
    file.rewind
    Donor.create(name: "Abada Capoeira", primary_contact: 'Tamara McDonald')
    Volunteer.create!(email: "beep@boop.bop", password: "asdfasdf", password_confirmation: "asdfasdf", name: "Cool Dude")
  end

  after do
    file.close
    file.unlink
  end

  it "makes a new donation request and updates donor contact info" do
    expect { BulkDonationRequestImport.new(file, Event.create(name: "Cool Auction").id, "2025 Donation: ").import }.to change(DonationRequest, :count).by(3)
    acrosports = Donor.where(name: "Acrosports").first
    expect(acrosports.email_address).to eq('info@acrosports.org')
    expect(acrosports.donor_type).to eq('business_nonprofit')
    expect(acrosports.donation_requests.last.notes).to eq("2025 Donation: Acro fun night $50 value")
    abada = Donor.where(name: "Abada Capoeira").first
    expect(abada.primary_contact).to eq('Tamara McDonald - office manager')
  end

  context "if a volunteer email is listed" do
    it "assigns that volunteer" do
      BulkDonationRequestImport.new(file, Event.create(name: "Cool Auction").id, "2025 Donation: ").import
      zombie = Donor.where(name: "Zed (Zombie)").first
      expect(zombie.donor_type).to eq("staff")
      expect(zombie.donation_requests.last.volunteer.email).to eq("beep@boop.bop")
    end
  end
end
