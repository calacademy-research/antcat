# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CollectReferences do
  describe "#call" do
    let(:protonym) do
      create :protonym,
        primary_type_information_taxt: "see {ref #{reference_1.id}}",
        secondary_type_information_taxt: "see {ref #{reference_2.id}}",
        type_notes_taxt: "see {ref #{reference_3.id}}",
        notes_taxt: "see {ref #{reference_4.id}}"
    end
    let(:taxon) { create :any_taxon, protonym: protonym }
    let(:reference_1) { create :any_reference }
    let(:reference_2) { create :any_reference }
    let(:reference_3) { create :any_reference }
    let(:reference_4) { create :any_reference }
    let(:reference_5) { create :any_reference }
    let(:reference_6) { create :any_reference }

    before do
      create :history_item, protonym: protonym, taxt: "see {ref #{reference_5.id}}"
      create :reference_section, taxon: taxon, references_taxt: "see {ref #{reference_6.id}}"
    end

    it 'collects references from various sources appearing on its catalog page' do
      expect(described_class[taxon]).to match_array [
        taxon.authorship_reference,
        reference_5,
        reference_6,
        reference_1,
        reference_2,
        reference_3,
        reference_4
      ]
    end
  end
end
