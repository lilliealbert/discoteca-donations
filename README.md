# DiscotecaDonations

A Rails application for managing donation collection and auction listings for school fundraising events. Built for DiscoTECA, a bilingual school auction.

## Features

### Donation Management
- Track the full lifecycle of donation solicitations from initial ask to received
- Assign volunteers to donation requests and monitor their progress
- Record donation details including type (digital/physical), quantity, and restrictions
- Mark donations as "in hand" when received

### Volunteer Coordination
- Volunteer authentication with admin roles
- Track volunteer activity and assigned donation requests
- Dashboard showing request status (unasked, asked, confirmed, declined)

### AI-Powered Auction Listings
- Automatically generate bilingual (English/Spanish) auction descriptions using Claude AI
- Categorize items (experiences, camps, museums, sports, food, etc.)
- Manage listing status from draft through export
- Export auction-ready CSV files for event management systems

### Public Donation Portal
- Allow external donors to submit donation offers without an account
- Automatic donor record creation

### Data Import/Export
- Bulk import donation requests from CSV
- Export donations, donation requests, and auction listings to CSV

## Requirements

- Ruby 3.2.2
- PostgreSQL
- Node.js 25.x
- Anthropic API key (for AI listing generation)

## Development Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd discoteca-donations
```

### 2. Install dependencies

```bash
bundle install
npm install
```

### 3. Configure environment

Create a `.env` file or set environment variables:

```bash
# Required for AI listing generation
ANTHROPIC_API_KEY=your_api_key_here
```

### 4. Setup database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # if seed data exists
```

### 5. Build assets

```bash
npm run build
npm run build:css
```

### 6. Start the server

```bash
bin/dev
```

This starts the Rails server along with asset watchers for JavaScript and CSS.

## Running Tests

```bash
bundle exec rspec
```

## Key Models

| Model | Purpose |
|-------|---------|
| **Volunteer** | Users who solicit donations and manage the system |
| **Donor** | Individuals or businesses providing donations |
| **Event** | Fundraising events (e.g., DiscoTECA 2026) |
| **DonationRequest** | Tracks solicitation status for each donor/event |
| **Donation** | Actual donations received with details |
| **AuctionListing** | Auction item generated from a donation |

## Donation Request Workflow

```
unasked → asked_once → asked_twice → asked_thrice → yes/no
                                                      ↓
                                                  Donation created
                                                      ↓
                                              AuctionListing generated
```

## Tech Stack

- **Framework**: Rails 8.1
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS 4.0
- **JavaScript**: esbuild
- **Authentication**: Devise
- **Authorization**: Pundit
- **AI Integration**: Anthropic Claude API
