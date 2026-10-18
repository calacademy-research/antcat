# frozen_string_literal: true

require 'rails_helper'

describe "Parameter filtering in logs" do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }

  it "filters email addresses and people's names from sign-up, account and feedback forms" do
    params = {
      "user" => { "email" => "someone@example.com", "name" => "Some One", "password" => "x" },
      "feedback" => { "email" => "someone@example.com", "name" => "Some One", "comment" => "Nice" },
      "email" => "someone@example.com"
    }

    filtered = filter.filter(params)

    expect(filtered["user"]).to eq("email" => "[FILTERED]", "name" => "[FILTERED]", "password" => "[FILTERED]")
    expect(filtered["feedback"]).to eq("email" => "[FILTERED]", "name" => "[FILTERED]", "comment" => "Nice")
    expect(filtered["email"]).to eq "[FILTERED]"
  end

  it "keeps taxon and author names in search parameters" do
    params = { "name" => "Lasius", "author_name" => "Bolton", "qq" => "Formica" }
    expect(filter.filter(params)).to eq params
  end
end
