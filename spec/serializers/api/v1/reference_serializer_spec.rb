# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferenceSerializer do
  describe "#as_json" do
    let!(:reference) { create :article_reference, :with_notes }

    specify do
      expect(described_class.new(reference).as_json).to eq(
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
            "review_state" => Reference::REVIEW_STATE_NONE,
            "bolton_key" => nil,
            "author_names_suffix" => nil,

            # Type-specific.
            "journal_id" => reference.journal.id,
            "publisher_id" => nil,
            "series_volume_issue" => reference.series_volume_issue,
            "nesting_reference_id" => nil,

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
  end
end
