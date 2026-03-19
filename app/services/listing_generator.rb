class ListingGenerator
  SYSTEM_PROMPT = <<~PROMPT
    You are a bilingual expert auction listing copywriter for a bilingual (English and Spanish) school fundraising auction.
    Your job is to create compelling, concise descriptions that encourage bidding and can be read in both languages.

    Guidelines:
    - Be enthusiastic but professional
    - Aim for a down-to-earth, warm, fellow-parent tone
    - Use emojis, but not too many
    - Highlight unique value and experiences
    - Use active voice
    - For short_description: MUST be 70 characters or less, highlight one supporting detail not obvious from the title (it's a subheader). Start with English version, then a separator character, then the Spanish version 
    - For long_description: 2-4 sentences, include all relevant details + fine print. After the paragraph selling the item (which should end with the organization's website), include the fine print in bullet-point format after "Fine print:\n". Format with a blank line, then "--", then another blank line between languages, like this:

      English description here.
      
      Learn more at: organization URL
      
      --

      Spanish description here.
      
      Más información en: URL

      --      
      
      Fine Print:
      - Detail 1
      - Detail 2

      Detalles:
      - detalle 1
      - detalle 2
    - For title: Clear, descriptive, 5-10 words. Start with English version, then a separator character, then the Spanish version
  PROMPT

  Result = Data.define(:success, :data, :error) do
    def initialize(success:, data: nil, error: nil)
      super
    end
  end

  def initialize(donation)
    @donation = donation
  end

  def generate
    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 1500,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: build_user_prompt }]
    )

    parse_response(response)
  rescue Anthropic::Errors::APIError => e
    Rails.logger.error("Anthropic API error: #{e.message}")
    error_result(e.message)
  rescue StandardError => e
    Rails.logger.error("ListingGenerator error: #{e.message}")
    error_result("An unexpected error occurred")
  end

  private

  def client
    @client ||= Anthropic::Client.new(
      api_key: api_key
    )
  end

  def api_key
    Rails.application.credentials.dig(:anthropic, :api_key) || ENV["ANTHROPIC_API_KEY"]
  end

  def build_user_prompt
    <<~PROMPT
      Create an auction listing for this donated item:

      Item Description: #{@donation.short_description}
      Additional Notes: #{@donation.notes}
      Terms/Restrictions: #{@donation.fine_print}
      Donation Type: #{@donation.donation_type}
      Donor: #{@donation.donor.name}

      Return a JSON object with exactly these fields:
      - title: A compelling title (5-10 words in each language)
      - short_description: A supporting detail (MAXIMUM 70 characters)
      - long_description: Full details (2-4 sentences in each language)
      - category: One of these exact values: #{AuctionListing.categories.keys.join(", ")}

      Return ONLY valid JSON, no other text.
    PROMPT
  end

  def parse_response(response)
    content = response.content.first.text
    json = JSON.parse(extract_json(content))

    # Enforce short_description limit
    json["short_description"] = json["short_description"].to_s[0, 70]

    Result.new(success: true, data: json)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Anthropic response: #{content}")
    error_result("Invalid response format")
  end

  def extract_json(content)
    # Try to extract JSON from markdown code blocks
    if content =~ /```(?:json)?\s*(\{[\s\S]*?\})\s*```/
      return $1
    end

    # Try to find raw JSON object
    if content =~ /(\{[\s\S]*\})/
      return $1
    end

    # Return as-is and let JSON.parse handle it
    content
  end

  def error_result(message)
    Result.new(success: false, error: message)
  end
end
