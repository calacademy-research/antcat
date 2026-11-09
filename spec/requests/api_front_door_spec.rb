# frozen_string_literal: true

require 'rails_helper'

# The API front door and the guide for programs and AI agents (2026-11-08, AntWeb step 6, API keys PR 1).
describe "API front door" do
  it "describes the API, its terms, licence and documentation at /v1" do
    get "/v1"

    expect(response).to have_http_status :ok
    json = response.parsed_body
    expect(json["name"]).to eq "AntCat API v1"
    expect(json["documentation"]).to eq "https://www.antcat.org/api_docs"
    expect(json["guide_for_programs"]).to eq "https://www.antcat.org/llms.txt"
    expect(json["license"]["name"]).to eq "CC BY 4.0"
    expect(json["terms"].join(" ")).to include "arranged in advance"
    expect(json["citation"]).to eq ApiAccess::CITATION
  end

  it "answers the same at /v1/" do
    get "/v1/"
    expect(response).to have_http_status :ok
  end

  it "keeps /llms.txt in step with the front door" do
    get "/llms.txt"

    expect(response).to have_http_status :ok
    expect(response.media_type).to eq 'text/plain'
    text = response.body
    expect(text).to include "https://www.antcat.org/v1", "CC BY 4.0", "antcat@antcat.org"
    Api::V1::RootController::TERMS.grep(/^Cite AntCat: /).each do |term|
      expect(text).to include term.delete_prefix("Cite AntCat: ")
    end
  end

  context "when API keys are off (the default)" do
    it "says keys are coming, without a link to the form" do
      get "/v1"
      expect(response.parsed_body["api_keys"]["status"]).to eq "coming"
      expect(response.body).not_to include ApiAccess::REGISTER_URL

      get "/llms.txt"
      expect(response.body).to include "Free registered API keys are coming"
      expect(response.body).not_to include ApiAccess::REGISTER_URL
    end
  end

  context "when API keys are on" do
    before { Settings.api_keys.enabled = true }

    it "links to the form and lists the limits" do
      get "/v1"
      api_keys = response.parsed_body["api_keys"]
      expect(api_keys["status"]).to eq "live"
      expect(api_keys["get_a_key"]).to eq "https://www.antcat.org/api_keys/new"
      expect(api_keys["header"]).to eq "X-API-Key"
      expect(api_keys["limits"]["without_key"]).to include "5 requests a minute", "50 requests a day", "25 records per page"
      expect(api_keys["limits"]["with_key"]).to eq(
        "60 requests a minute, 5,000 requests a day, 100 records per page, 50,000 records a day"
      )

      get "/llms.txt"
      expect(response.body).to include ApiAccess::REGISTER_URL, "X-API-Key", "60 requests a minute"
      expect(response.body).not_to include "coming"
    end
  end
end
