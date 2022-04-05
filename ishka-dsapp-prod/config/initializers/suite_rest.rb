# frozen_string_literal: true

SuiteRest.configure do |config|
  config.account = Rails.application.credentials[Rails.env.to_sym][:NETSUITE_ACCOUNT]
  config.consumer_key =  Rails.application.credentials[Rails.env.to_sym][:CONSUMER_KEY]
  config.consumer_secret = Rails.application.credentials[Rails.env.to_sym][:CONSUMER_SECRET]
  config.token_id = Rails.application.credentials[Rails.env.to_sym][:TOKEN_ID]
  config.token_secret = Rails.application.credentials[Rails.env.to_sym][:TOKEN_SECRET]
  config.base_url = Rails.application.credentials[Rails.env.to_sym][:BASE_URL]

  config.sandbox = Rails.env.production? ? false : true
end
