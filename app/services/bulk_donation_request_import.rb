require "csv"
class BulkDonationRequestImport
  def initialize(file, event_id, note_prefix)
    @file = file
    @event_id = event_id
    @note_prefix = note_prefix
  end

  def import
    raise "No event provided" unless @event_id

    contents = CSV.parse(@file.read)
    headers = contents.shift
    puts "HEY THERE, you're creating #{contents.length} donation requests"

    # 0: Name
    # 1: Primary Contact
    # 2: Email
    # 3: Phone
    # 4: Website
    # 5: Relationship to TECA
    # 6: Donor Notes
    # 7: Donor Type
    # 8: Donation Notes

    contents.each do |row|
      donor = Donor.find_or_create_by(name: row[0])
      donor.primary_contact = row[1] if row[1].present?
      donor.email_address = row[2] if row[2].present?
      donor.phone_number = row[3] if row[3].present?
      donor.website = row[4] if row[4].present?
      donor.relationship_to_teca = row[5] if row[5].present?
      donor.notes = row[6] if row[6].present?
      donor.donor_type = parse_type(row[7]) if row[7].present?
      donor.save!

      DonationRequest.create!(event_id: @event_id, donor: donor, notes: "#{@note_prefix}#{row[8]}")
    end
  end

  private

  def parse_type(type)
    case type
    when "Family" || "family"
      "family"
    when "Staff" || "staff"
      "staff"
    when "Business/Non-profit" || "business/non-profit"
      "business_nonprofit"
    end
  end
end


