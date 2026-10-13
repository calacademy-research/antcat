# frozen_string_literal: true

# `Aws.config[:s3] = { stub_responses: true }` (see `rails_helper.rb`) makes S3 clients record requests instead of
# sending them. A fresh client per example keeps `References::DocumentStorage.client.api_requests` per example.
RSpec.configure do |config|
  config.before do
    References::DocumentStorage.reset_client!
  end
end

module ReferenceDocumentStorageHelpers
  def s3_requests operation_name
    References::DocumentStorage.client.api_requests.select { |request| request[:operation_name] == operation_name }
  end

  def unconfigured_s3_settings
    Config::Options.new(access_key_id: nil, secret_access_key: nil, bucket: nil, region: nil)
  end
end

RSpec.configure do |config|
  config.include ReferenceDocumentStorageHelpers
end
