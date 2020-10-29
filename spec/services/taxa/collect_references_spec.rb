# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CollectReferences do
  describe "#call" do
    let!(:taxon) { create :any_taxon }
    let!(:reference_1) { create :any_reference }
    let!(:reference_2) { create :any_reference }
    let!(:reference_5) { create :any_reference }
    let!(:reference_6) { create :any_reference }
    let!(:reference_7) { create :any_reference }
    let!(:reference_8) { create :any_reference }

    before do
      taxon.protonym.update!(
        primary_type_information_taxt: "see {ref #{reference_5.id}}",
        secondary_type_information_taxt: "see {ref #{reference_6.id}}",
        type_notes_taxt: "see {ref #{reference_7.id}}",
        notes_taxt: "see {ref #{reference_8.id}}"
      )

      create :history_item, protonym: taxon.protonym, taxt: "see {ref #{reference_1.id}}"
      create :reference_section, taxon: taxon, references_taxt: "see {ref #{reference_2.id}}"
    end

    it 'collects references from various sources appearing on its catalog page' do
      expect(described_class[taxon]).to match_array [
        taxon.authorship_reference,
        reference_1,
        reference_2,
        reference_5,
        reference_6,
        reference_7,
        reference_8
      ]
    end
  end
end
