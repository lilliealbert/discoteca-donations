# The Anthropic gem reads from ANTHROPIC_API_KEY environment variable by default.
# For production, set this via environment variables.
# For development, you can set it in config/credentials.yml.enc
#
# To use credentials, the ListingGenerator service reads from:
#   Rails.application.credentials.dig(:anthropic, :api_key)
