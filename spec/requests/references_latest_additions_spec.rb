# frozen_string_literal: true

require 'rails_helper'

# GET /references/latest_additions (anyone): the references menu's first page, newest first
# (docs/catalog/routes.tsv; added 2026-11-16 with step 5, every kept route names its test).
describe "References, latest additions" do
  it "lists references newest first, with the date each was added" do
    older = create :any_reference, title: "Older ants of the forest", created_at: Time.zone.parse("2026-11-01 12:00")
    newer = create :any_reference, title: "Newer ants of the desert", created_at: Time.zone.parse("2026-11-10 12:00")

    get references_latest_additions_path

    expect(response).to have_http_status :ok
    body = response.body
    expect(body).to include("Latest Additions", older.title, newer.title)
    expect(body.index(newer.title)).to be < body.index(older.title)
    expect(body).to include %(datetime="2026-11-10")
  end

  it "shows New to helpers, not to visitors" do
    get references_latest_additions_path
    expect(response).to have_http_status :ok
    expect(response.body).not_to include %(href="#{new_reference_path}")

    sign_in create(:user, :helper)
    get references_latest_additions_path
    expect(response).to have_http_status :ok
    expect(response.body).to include %(href="#{new_reference_path}")
  end
end
