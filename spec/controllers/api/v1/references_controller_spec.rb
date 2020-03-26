# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferencesController, as: :visitor do
  describe "GET index" do
    specify do
      reference = create :article_reference
      get :index
      expect(json_response).to eq([reference.as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference) { create :article_reference }

    specify do
      get :show, params: { id: reference.id }
      expect(json_response).to eq(
        {
          "article_reference" => {
            "author_names_string_cache" => reference.author_names_string_cache,
            "author_names_suffix" => nil,
            "bolton_key" => nil,
            "citation" => nil,
            "citation_year" => reference.citation_year,
            "created_at" => reference.created_at.as_json,
            "date" => nil,
            "doi" => nil,
            "editor_notes" => nil,
            "expandable_reference_cache" => nil,
            "expanded_reference_cache" => nil,
            "id" => reference.id,
            "journal_id" => reference.journal_id,
            "nesting_reference_id" => nil,
            "online_early" => false,
            "pagination" => reference.pagination,
            "plain_text_cache" => nil,
            "public_notes" => nil,
            "publisher_id" => nil,
            "reason_missing" => nil,
            "review_state" => "none",
            "series_volume_issue" => reference.series_volume_issue,
            "taxonomic_notes" => nil,
            "title" => reference.title,
            "updated_at" => reference.updated_at.as_json,
            "year" => reference.year
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: reference.id })).to have_http_status :ok }
  end
end
