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
    expect(json["terms"].join(" ")).to include "not to copy the catalog"
  end

  it "answers the same at /v1/" do
    get "/v1/"
    expect(response).to have_http_status :ok
  end

  it "keeps public/llms.txt in step with the front door" do
    text = Rails.public_path.join("llms.txt").read
    expect(text).to include "https://www.antcat.org/v1", "CC BY 4.0", "antcat@antcat.org"
    Api::V1::RootController::TERMS.grep(/^Cite AntCat: /).each do |term|
      expect(text).to include term.delete_prefix("Cite AntCat: ")
    end
  end
end
