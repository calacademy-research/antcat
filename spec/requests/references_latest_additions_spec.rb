# frozen_string_literal: true

require 'rails_helper'

# GET /references/latest_additions (anyone): the references menu's first page, newest first
# (docs/catalog/routes.tsv; added 2026-11-16 with step 5, every kept route names its test).
describe "References, latest additions" do
  it "lists references newest first, with the date each was added" do
    older = create :any_reference, title: "Older ants of the forest", created_at: 3.days.ago
    newer = create :any_reference, title: "Newer ants of the desert", created_at: 1.day.ago

    get references_latest_additions_path

    expect(response).to have_http_status :ok
    body = response.body
    expect(body).to include "Latest Additions"
    expect(body.index(newer.title)).to be < body.index(older.title)
    expect(body).to include newer.created_at.to_date.iso8601
  end

  it "offers New only to helpers and above" do
    get references_latest_additions_path
    expect(response.body).not_to include new_reference_path
  end
end
