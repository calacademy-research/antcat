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
            "year_suffix" => reference.year_suffix,
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

            # Notes (editor and taxonomic notes are for signed-in users only).
            "public_notes" => reference.public_notes,

            # Caches.
            "author_names_string_cache" => reference.author_names_string_cache,

            "created_at" => reference.created_at.as_json,
            "updated_at" => reference.updated_at.as_json
          }
        }
      )
    end

    it "does not include notes shown to signed-in users only" do
      json = described_class.new(reference).as_json["article_reference"]

      expect(reference.editor_notes).to be_present
      expect(reference.taxonomic_notes).to be_present
      expect(json.keys).not_to include("editor_notes", "taxonomic_notes")
    end
  end
end
