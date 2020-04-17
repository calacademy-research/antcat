# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferencesController, as: :visitor do
  describe "GET index" do
    specify do
      reference = create :any_reference
      get :index
      expect(json_response).to eq([reference.as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference) { create :article_reference, :with_notes }

    specify do
      get :show, params: { id: reference.id }
      expect(json_response).to eq(
        {
          "article_reference" => {
            "id" => reference.id,
            "title" => reference.title,
            "year" => reference.year,
            "citation_year" => reference.citation_year,
            "stated_year" => reference.stated_year,
            "date" => nil,
            "doi" => nil,
            "online_early" => false,
            "pagination" => reference.pagination,
            "review_state" => "none",
            "bolton_key" => nil,
            "author_names_suffix" => nil,

            # Type-specific.
            "journal_id" => reference.journal_id,
            "publisher_id" => nil,
            "series_volume_issue" => reference.series_volume_issue,
            "nesting_reference_id" => nil,
            # TODO: Remove `citation` from here and from database.
            "citation" => nil,

            # Notes.
            "public_notes" => reference.public_notes,
            "editor_notes" => reference.editor_notes,
            "taxonomic_notes" => reference.taxonomic_notes,

            # Caches.
            "plain_text_cache" => nil,
            "expanded_reference_cache" => nil,
            "expandable_reference_cache" => nil,
            "author_names_string_cache" => reference.author_names_string_cache,

            "created_at" => reference.created_at.as_json,
            "updated_at" => reference.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: reference.id })).to have_http_status :ok }
  end
end
