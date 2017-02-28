VCR.configure do |config|
  config.cassette_library_dir = "#{File.dirname(__FILE__)}/vcr_cassettes"
  config.hook_into :faraday
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  config.before_record do |record|
    record.request.headers.merge!(
      CleverTap::Client::ACCOUNT_HEADER => ['fake_account_id'],
      CleverTap::Client::PASSCODE_HEADER => ['fake_passcode']
    )
  end
end
