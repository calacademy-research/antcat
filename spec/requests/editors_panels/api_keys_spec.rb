# frozen_string_literal: true

require 'rails_helper'

describe "API keys admin page (/panel/api_keys)" do
  let!(:api_key) { create(:api_key, name: 'Quintus Batiatus', project: 'Campania checklist').tap(&:issue_key!) }

  context "when not a superadmin" do
    it "is not available" do
      sign_in create(:user, :editor)
      get panel_api_keys_path
      expect(response).to have_http_status :forbidden

      put revoke_panel_api_key_path(api_key)
      expect(api_key.reload.status).to eq ApiKey::ACTIVE
    end
  end

  context "when a superadmin" do
    before { sign_in create(:user, :superadmin) }

    it "lists registrations with their usage" do
      today = Time.current.utc.to_date
      ApiUsageDay.add day: today, api_key_id: api_key.id, client: "", requests: 7, records: 300, rejected: 2
      ApiUsageDay.add day: today, api_key_id: ApiAccess::NO_KEY_ID, client: "abc", requests: 3

      get panel_api_keys_path

      expect(response).to have_http_status :ok
      expect(response.body).to include 'Quintus Batiatus', 'Campania checklist', api_key.key_prefix, '300'
      expect(response.body).to include "Requests without a key"
    end

    it "downloads a CSV" do
      get panel_api_keys_path(format: :csv)

      expect(response).to have_http_status :ok
      expect(response.media_type).to eq 'text/csv'
      expect(response.body.lines.first).to start_with '"id","name","email"'
      expect(response.body).to include '"Quintus Batiatus"'
    end

    # A spreadsheet runs a cell that starts with =, +, - or @ as a formula, some also after spaces.
    it "marks text a spreadsheet would run as a formula, also after spaces" do
      create :api_key, name: 'Plain Name', institution: '=HYPERLINK("http://example.org")', project: "+1+1"
      # Leading spaces are stripped when a registration is saved; a row written another way keeps them.
      spaced = create :api_key, name: 'Spaced'
      spaced.update_columns institution: '  =1+1', project: " \t@SUM(A1)", note: "-2"

      get panel_api_keys_path(format: :csv)

      expect(response.body).to include %("'=HYPERLINK(""http://example.org"")"), %("'+1+1")
      expect(response.body).to include %("'  =1+1"), %("' \t@SUM(A1)"), %("'-2")
      expect(response.body).to include '"Plain Name"', '"Spaced"'
      expect(response.body).not_to include %("'Plain Name"), %("'Spaced")
    end

    it "revokes and reactivates a key" do
      put revoke_panel_api_key_path(api_key)
      expect(api_key.reload.status).to eq ApiKey::REVOKED

      put reactivate_panel_api_key_path(api_key)
      expect(api_key.reload.status).to eq ApiKey::ACTIVE
    end

    it "sets the level, per-key limits and a note; blank limits mean the level's value" do
      put panel_api_key_path(api_key), params: {
        api_key: { level: ApiKey::COLLABORATOR, requests_per_day: '20000', records_per_page: '', note: 'Revision of Pheidole' }
      }

      expect(response).to redirect_to panel_api_keys_path
      api_key.reload
      expect(api_key).to have_attributes(
        level: ApiKey::COLLABORATOR, requests_per_day: 20_000, records_per_page: nil, note: 'Revision of Pheidole'
      )
      expect(api_key.limits.requests_per_day).to eq 20_000
    end

    it "does not accept limits above the maximum" do
      put panel_api_key_path(api_key), params: { api_key: { records_per_page: '5000' } }
      expect(response).to have_http_status :unprocessable_content
      expect(api_key.reload.records_per_page).to be_nil
    end
  end
end
