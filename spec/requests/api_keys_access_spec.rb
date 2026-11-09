# frozen_string_literal: true

require 'rails_helper'

# Free registered API keys and the /v1 limits (see `ApiAccess`), decided by Brian Fisher 2026-11-08.
describe "API keys and limits" do
  let!(:taxon) { create :species }

  def api_get path, key: nil, ip: '203.0.113.7'
    headers = key ? { ApiAccess::HEADER => key } : {}
    get path, headers: headers, env: { 'REMOTE_ADDR' => ip }
  end

  def issued_key **attributes
    api_key = create :api_key, **attributes
    [api_key, api_key.issue_key!]
  end

  context "when API keys are off (the default)" do
    it "answers as before: no key needed for lists, 100 records per page, nothing counted" do
      expect(ApiAccess.enabled?).to be false

      10.times { api_get "/v1/taxa/#{taxon.id}" }
      expect(response).to have_http_status :ok

      api_get "/v1/taxa"
      expect(response).to have_http_status :ok
      expect(ApiUsageDay.count).to eq 0
      expect(ApiUsageMinute.count).to eq 0
    end

    it "ignores keys, even ones that are not valid" do
      api_get "/v1/taxa", key: "ac_not-a-key"
      expect(response).to have_http_status :ok
    end

    it "gives 100 records per page" do
      queries = []
      callback = ->(*, payload) { queries << payload[:sql] }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { api_get "/v1/taxa" }

      expect(queries.grep(/FROM `taxa`.* LIMIT 100\b/)).to be_present
    end
  end

  context "when API keys are on" do
    before { Settings.api_keys.enabled = true }

    describe "requests without a key" do
      it "answers single records" do
        api_get "/v1/taxa/#{taxon.id}"
        expect(response).to have_http_status :ok
        expect(response.parsed_body["id"]).to eq taxon.id
      end

      it "needs a key for lists of all records" do
        api_get "/v1/taxa"

        expect(response).to have_http_status :unauthorized
        expect(response.headers['WWW-Authenticate']).to include ApiAccess::HEADER
        expect(response.parsed_body["message"]).to include "need a free API key", ApiAccess::REGISTER_URL
      end

      it "answers 429 with Retry-After after 5 requests a minute" do
        travel_to Time.utc(2026, 11, 8, 12, 0, 20) do
          5.times do
            api_get "/v1/taxa/#{taxon.id}"
            expect(response).to have_http_status :ok
          end

          api_get "/v1/taxa/#{taxon.id}"
        end

        expect(response).to have_http_status :too_many_requests
        expect(response.headers['Retry-After']).to eq "40"
        json = response.parsed_body
        expect(json["retry_after_seconds"]).to eq 40
        expect(json["message"]).to include(
          "visitors without an API key: 5 requests a minute", "wait 40 seconds",
          "get a free API key at https://www.antcat.org/api_keys/new", "antcat@antcat.org", ApiAccess::CITATION
        )
        expect(json["citation"]).to eq ApiAccess::CITATION
        expect(ApiAccess::CITATION).to eq Api::V1::RootController::TERMS.grep(/\ACite AntCat: /).sole.delete_prefix("Cite AntCat: ")
      end

      it "counts each IP on its own" do
        5.times { api_get "/v1/taxa/#{taxon.id}" }
        api_get "/v1/taxa/#{taxon.id}", ip: '198.51.100.9'
        expect(response).to have_http_status :ok
      end

      it "never limits or counts the front door" do
        10.times { api_get "/v1" }
        expect(response).to have_http_status :ok
        expect(ApiUsageDay.count).to eq 0
      end
    end

    describe "requests with a key" do
      let!(:issued) { issued_key }
      let(:api_key) { issued.first }
      let(:key) { issued.last }

      it "lists records, 100 per page, and counts requests and records" do
        api_get "/v1/taxa", key: key

        expect(response).to have_http_status :ok
        expect(response.parsed_body.size).to eq 1
        expect(ApiUsageDay.find_by(api_key_id: api_key.id)).to have_attributes(requests: 1, records: 1, client: "")
      end

      it "allows more than the no-key limit" do
        10.times { api_get "/v1/taxa/#{taxon.id}", key: key }
        expect(response).to have_http_status :ok
      end

      it "answers 401 for an unknown key" do
        api_get "/v1/taxa/#{taxon.id}", key: "ac_#{'x' * 40}"

        expect(response).to have_http_status :unauthorized
        expect(response.parsed_body["message"]).to include "not valid", ApiAccess::REGISTER_URL
      end

      it "answers 401 for a revoked key" do
        api_key.revoke!
        api_get "/v1/taxa/#{taxon.id}", key: key
        expect(response).to have_http_status :unauthorized
      end

      it "does not accept the key in the web address" do
        get "/v1/taxa", params: { api_key: key }
        expect(response).to have_http_status :unauthorized
        expect(response.parsed_body["error"]).to eq "API key needed"
      end

      it "uses per-key limits" do
        api_key.update!(requests_per_minute: 2, records_per_page: 1)
        create :species

        api_get "/v1/taxa", key: key
        expect(response.parsed_body.size).to eq 1

        api_get "/v1/taxa", key: key
        api_get "/v1/taxa", key: key
        expect(response).to have_http_status :too_many_requests
        expect(response.headers['Retry-After'].to_i).to be_between(1, 60)
        expect(response.parsed_body["message"]).to include "your API key: 2 requests a minute"
        expect(response.parsed_body["message"]).not_to include "get a free API key"
      end

      it "stops at the daily requests limit until the next UTC day" do
        api_key.update!(requests_per_day: 1)

        travel_to Time.utc(2026, 11, 8, 23, 59, 0) do
          api_get "/v1/taxa/#{taxon.id}", key: key
          api_get "/v1/taxa/#{taxon.id}", key: key
          expect(response).to have_http_status :too_many_requests
          expect(response.headers['Retry-After']).to eq "60"
          expect(response.parsed_body["message"]).to include "1 request a day", "until tomorrow (UTC)"
        end

        travel_to Time.utc(2026, 11, 9, 0, 0, 1) do
          api_get "/v1/taxa/#{taxon.id}", key: key
          expect(response).to have_http_status :ok
        end
      end

      it "counts 429s for the key" do
        api_key.update!(requests_per_minute: 1)
        2.times { api_get "/v1/taxa/#{taxon.id}", key: key }
        expect(ApiUsageDay.find_by(api_key_id: api_key.id)).to have_attributes(requests: 1, rejected: 1)
      end
    end

    describe "logs" do
      let(:log) { StringIO.new }

      let(:logged) { [Rails, ActionController::Base, ActiveRecord::Base, ActionMailer::Base, ActionView::Base] }

      around do |example|
        original_loggers = logged.map(&:logger)
        logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log))
        logged.each { it.logger = logger }
        example.run
      ensure
        logged.zip(original_loggers).each { |owner, original| owner.logger = original }
      end

      it "never has the key, from the page that shows it to the requests that use it" do
        api_key = build :api_key
        token = api_key.new_confirmation_token
        api_key.save!

        post issue_api_key_path, params: { token: token }
        key = response.body[/ac_[1-9A-HJ-NP-Za-km-z]{#{ApiKey::KEY_RANDOM_LENGTH}}/]
        expect(key).to be_present

        api_get "/v1/taxa", key: key
        api_get "/v1/taxa/#{taxon.id}", key: key
        expect(response).to have_http_status :ok

        expect(log.string).to include "ApiKeysController#issue", "Api::V1::TaxaController"
        expect(log.string).not_to include key
      end
    end
  end
end
