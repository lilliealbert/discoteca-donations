require 'rails_helper'

RSpec.describe ListingGenerator do
  let(:donor) { Donor.create!(name: "Rose Quartz") }
  let(:event) { Event.create!(name: "Beach City Fundraiser", date: Date.tomorrow) }
  let(:volunteer) { Volunteer.create!(email: "pearl@crystalgems.com", password: "password123", name: "Pearl") }
  let(:donation) do
    Donation.create!(
      donor: donor,
      event: event,
      volunteer: volunteer,
      donation_type: :physical,
      short_description: "Handmade shield with rose emblem",
      notes: "One-of-a-kind protective gear, perfect for display or light combat training",
      fine_print: "No returns. Must be picked up at the Temple."
    )
  end

  describe "#generate" do
    let(:client) { instance_double(Anthropic::Client) }
    let(:messages_resource) { double("messages") }

    before do
      allow(Anthropic::Client).to receive(:new).and_return(client)
      allow(client).to receive(:messages).and_return(messages_resource)
    end

    context "with successful API response" do
      let(:response_json) do
        {
          title: "Rose's Legendary Shield - Handcrafted Gem Artifact",
          short_description: "Own a piece of Gem history with this stunning rose-emblemed shield",
          long_description: "This magnificent handmade shield features an intricate rose emblem, crafted with care and attention to detail. Perfect for display in your home or for light combat training."
        }.to_json
      end

      let(:mock_response) do
        content_block = double("content_block", text: response_json)
        double("response", content: [content_block])
      end

      before do
        allow(messages_resource).to receive(:create).and_return(mock_response)
      end

      it "returns a successful result with generated content" do
        result = described_class.new(donation).generate

        expect(result.success).to be true
        expect(result.data["title"]).to include("Shield")
        expect(result.data["short_description"]).to be_present
        expect(result.data["long_description"]).to be_present
      end

      it "enforces the 70 character limit on short_description" do
        long_short_desc = "A" * 100
        long_response = double("content_block", text: {
          title: "Test Title",
          short_description: long_short_desc,
          long_description: "Test long description"
        }.to_json)
        long_mock_response = double("response", content: [long_response])

        allow(messages_resource).to receive(:create).and_return(long_mock_response)

        result = described_class.new(donation).generate

        expect(result.success).to be true
        expect(result.data["short_description"].length).to eq(70)
      end
    end

    context "with API error" do
      before do
        error = Anthropic::Errors::RateLimitError.new(
          url: URI.parse("https://api.anthropic.com/v1/messages"),
          status: 429,
          headers: {},
          body: nil,
          request: nil,
          response: nil,
          message: "Rate limit exceeded"
        )
        allow(messages_resource).to receive(:create).and_raise(error)
      end

      it "returns an error result" do
        result = described_class.new(donation).generate

        expect(result.success).to be false
        expect(result.error).to include("Rate limit exceeded")
      end
    end

    context "with invalid JSON response" do
      let(:mock_response) do
        content_block = double("content_block", text: "This is not valid JSON")
        double("response", content: [content_block])
      end

      before do
        allow(messages_resource).to receive(:create).and_return(mock_response)
      end

      it "returns an error result" do
        result = described_class.new(donation).generate

        expect(result.success).to be false
        expect(result.error).to eq("Invalid response format")
      end
    end

    context "with JSON wrapped in markdown code blocks" do
      let(:markdown_response) do
        <<~RESPONSE
          Here's the auction listing:

          ```json
          {
            "title": "Crystal Gem Shield",
            "short_description": "Protect yourself in style!",
            "long_description": "A beautiful handcrafted shield."
          }
          ```
        RESPONSE
      end

      let(:mock_response) do
        content_block = double("content_block", text: markdown_response)
        double("response", content: [content_block])
      end

      before do
        allow(messages_resource).to receive(:create).and_return(mock_response)
      end

      it "extracts and parses the JSON successfully" do
        result = described_class.new(donation).generate

        expect(result.success).to be true
        expect(result.data["title"]).to eq("Crystal Gem Shield")
        expect(result.data["short_description"]).to eq("Protect yourself in style!")
      end
    end
  end
end
