# Clear existing data
puts "Clearing existing data..."
DonationRequest.destroy_all
Donor.destroy_all
Event.destroy_all
Volunteer.destroy_all

# Create Volunteers (Crystal Gems)
puts "Creating volunteers..."
volunteers = [
  { email: "steven@crystalgems.com", password: "password123" },
  { email: "garnet@crystalgems.com", password: "password123" },
  { email: "amethyst@crystalgems.com", password: "password123" },
  { email: "pearl@crystalgems.com", password: "password123" },
  { email: "peridot@crystalgems.com", password: "password123" },
  { email: "lapis@crystalgems.com", password: "password123" }
].map do |attrs|
  Volunteer.create!(attrs)
end

# Create Events
puts "Creating events..."
events = [
  { name: "Beach City Concert", date: Date.today + 30 },
  { name: "Crystal Gem Gala", date: Date.today + 45 },
  { name: "Little Homeschool Fundraiser", date: Date.today + 60 },
  { name: "Big Donut Charity Drive", date: Date.today + 14 },
  { name: "Sadie Killer & The Suspects Benefit Show", date: Date.today + 21 },
  { name: "Beach City Pride Parade", date: Date.today + 90 },
  { name: "Fish Stew Pizza Community Dinner", date: Date.today + 7 }
].map do |attrs|
  Event.create!(attrs)
end

# Create Donors (Beach City residents and businesses)
puts "Creating donors..."
donors = [
  {
    name: "Greg Universe",
    email_address: "greg@universemusicshop.com",
    phone_number: "555-0101",
    website: "https://mrgreguniversemusic.com",
    relationship_to_teca: "Parent of volunteer, local musician",
    notes: "Former rock star, very generous with music equipment donations. Owns a car wash."
  },
  {
    name: "Sadie Miller",
    email_address: "sadie@bigdonut.com",
    phone_number: "555-0102",
    website: nil,
    relationship_to_teca: "Local business employee, musician",
    notes: "Works at the Big Donut. Lead singer of Sadie Killer & The Suspects."
  },
  {
    name: "Lars Barriga",
    email_address: "lars@spacepastries.com",
    phone_number: "555-0103",
    website: "https://spacepastries.com",
    relationship_to_teca: "Local business owner",
    notes: "Runs a bakery. Has a spaceship. It's a long story."
  },
  {
    name: "Kofi Pizza",
    email_address: "kofi@fishstewpizza.com",
    phone_number: "555-0104",
    website: "https://fishstewpizza.com",
    relationship_to_teca: "Local business owner",
    notes: "Owner of Fish Stew Pizza. Often donates food for events."
  },
  {
    name: "Nanefua Pizza",
    email_address: "nanefua@beachcity.gov",
    phone_number: "555-0105",
    website: nil,
    relationship_to_teca: "Mayor of Beach City",
    notes: "Current mayor. Very supportive of community initiatives."
  },
  {
    name: "Vidalia",
    email_address: "vidalia@beachcityart.com",
    phone_number: "555-0106",
    website: "https://vidaliaart.com",
    relationship_to_teca: "Local artist",
    notes: "Painter and artist. Mother of Onion and Sour Cream."
  },
  {
    name: "Jamie",
    email_address: "jamie@beachcitymail.com",
    phone_number: "555-0107",
    website: nil,
    relationship_to_teca: "Community member",
    notes: "Mail carrier and aspiring actor. Very enthusiastic volunteer."
  },
  {
    name: "Ronaldo Fryman",
    email_address: "ronaldo@keepbeachcityweird.com",
    phone_number: "555-0108",
    website: "https://keepbeachcityweird.com",
    relationship_to_teca: "Blogger, conspiracy theorist",
    notes: "Runs the Keep Beach City Weird blog. Donations may come with unsolicited theories."
  },
  {
    name: "Mr. Fryman",
    email_address: "fryman@beachcitywalk.com",
    phone_number: "555-0109",
    website: nil,
    relationship_to_teca: "Local business owner",
    notes: "Owns Beach Citywalk Fries. Great source for food donations."
  },
  {
    name: "Barb Miller",
    email_address: "barb@beachcitymail.com",
    phone_number: "555-0110",
    website: nil,
    relationship_to_teca: "Community member, mail carrier",
    notes: "Sadie's mom. Very supportive of local causes."
  },
  {
    name: "Connie Maheswaran",
    email_address: "connie@littlehomeschool.edu",
    phone_number: "555-0111",
    website: nil,
    relationship_to_teca: "Student, Crystal Gem ally",
    notes: "Skilled swordfighter and avid reader. Very organized."
  },
  {
    name: "Dr. Priyanka Maheswaran",
    email_address: "dr.maheswaran@beachcityhospital.com",
    phone_number: "555-0112",
    website: nil,
    relationship_to_teca: "Medical professional",
    notes: "Doctor at Beach City Hospital. Can help with first aid supplies."
  }
].map do |attrs|
  Donor.create!(attrs)
end

# Create Donation Requests
puts "Creating donation requests..."

donation_requests = [
  { donor: donors[0], volunteer: volunteers[0], event: events[0], request_status: :yes, notes: "Greg is donating his sound equipment for the concert!" },
  { donor: donors[1], volunteer: volunteers[2], event: events[0], request_status: :yes, notes: "Sadie will perform a set with her band." },
  { donor: donors[2], volunteer: volunteers[3], event: events[1], request_status: :asked_once, notes: "Reached out about pastry donations for the gala." },
  { donor: donors[3], volunteer: volunteers[0], event: events[6], request_status: :yes, notes: "Kofi is providing all the pizza for the community dinner!" },
  { donor: donors[4], volunteer: volunteers[1], event: events[5], request_status: :asked_twice, notes: "Mayor Nanefua will give opening remarks and city support." },
  { donor: donors[5], volunteer: volunteers[4], event: events[1], request_status: :unasked, notes: "Planning to ask about donating artwork for silent auction." },
  { donor: donors[6], volunteer: volunteers[5], event: events[4], request_status: :yes, notes: "Jamie volunteered to MC the benefit show." },
  { donor: donors[7], volunteer: volunteers[2], event: events[2], request_status: :no, notes: "Ronaldo wanted to give a 3-hour presentation. We politely declined." },
  { donor: donors[8], volunteer: volunteers[0], event: events[3], request_status: :yes, notes: "Donating fry bits for the charity drive snack table." },
  { donor: donors[9], volunteer: volunteers[1], event: events[4], request_status: :asked_once, notes: "Barb offered to help with logistics." },
  { donor: donors[10], volunteer: volunteers[0], event: events[2], request_status: :asked_thrice, notes: "Connie will help organize the Little Homeschool event." },
  { donor: donors[11], volunteer: volunteers[3], event: events[3], request_status: :yes, notes: "Dr. Maheswaran donating first aid kits." },
  { donor: donors[0], volunteer: volunteers[0], event: events[4], request_status: :asked_twice, notes: "Greg offering to open for Sadie Killer." },
  { donor: donors[3], volunteer: volunteers[2], event: events[0], request_status: :unasked, notes: "Need to follow up about food truck at concert." }
]

donation_requests.each do |attrs|
  DonationRequest.create!(attrs)
end

puts "Seed complete!"
puts "  - #{Volunteer.count} volunteers"
puts "  - #{Event.count} events"
puts "  - #{Donor.count} donors"
puts "  - #{DonationRequest.count} donation requests"
puts ""
puts "You can log in with any volunteer email (e.g., steven@crystalgems.com) with password: password123"