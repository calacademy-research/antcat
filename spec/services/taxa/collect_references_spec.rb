# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CollectReferences do
  describe "#call" do
    describe 'collecting references from various locations' do
      let(:protonym) do
        create :protonym,
          primary_type_information_taxt: Taxt.ref(reference_1.id),
          secondary_type_information_taxt: Taxt.ref(reference_2.id),
          type_notes_taxt: Taxt.ref(reference_3.id),
          notes_taxt: Taxt.ref(reference_4.id)
      end
      let(:taxon) { create :any_taxon, protonym: protonym }
      let(:reference_1) { create :any_reference }
      let(:reference_2) { create :any_reference }
      let(:reference_3) { create :any_reference }
      let(:reference_4) { create :any_reference }
      let(:reference_5) { create :any_reference }

      before do
        create :reference_section, taxon: taxon, references_taxt: Taxt.ref(reference_5.id)
      end

      it 'collects references from various sources appearing on its catalog page' do
        expect(described_class[taxon]).to match_array [
          taxon.authorship_reference,
          reference_5,
          reference_1,
          reference_2,
          reference_3,
          reference_4
        ]
      end
    end

    describe "collecting references from history items" do
      context 'with references in `TAXT` history items' do
        let(:protonym) { create :protonym }
        let(:taxon) { create :any_taxon, protonym: protonym }
        let(:reference_1) { create :any_reference }

        before do
          create :history_item, :taxt, protonym: protonym, taxt: Taxt.ref(reference_1.id)
        end

        it 'includes hardcoded references' do
          expect(described_class[taxon]).to match_array [
            taxon.authorship_reference,
            reference_1
          ]
        end
      end

      context 'with references in relational history items' do
        let(:protonym) { create :protonym }
        let(:taxon) { create :any_taxon, protonym: protonym }
        let(:reference_1) { create :any_reference }

        before do
          create :history_item, :combination_in, protonym: protonym, reference: reference_1
        end

        it 'includes relational references' do
          expect(described_class[taxon]).to match_array [
            taxon.authorship_reference,
            reference_1
          ]
        end
      end
    end
  end

  describe "hidden notes and reference section titles" do
    let(:taxon) { create :genus }
    let(:hidden_reference) { create :any_reference }
    let(:title_reference) { create :any_reference }

    before do
      create :reference_section, taxon: taxon,
        title_taxt: Taxt.ref(title_reference.id),
        references_taxt: "Visible text {hiddennote see #{Taxt.ref(hidden_reference.id)}}"
    end

    it "lists a reference cited only in a hidden note to signed-in users only" do
      Current.set(signed_in: false) { expect(described_class[taxon]).not_to include hidden_reference }
      Current.set(signed_in: true) { expect(described_class[taxon]).to include hidden_reference }
    end

    it "lists references in section titles" do
      expect(described_class[taxon]).to include title_reference
    end
  end
end
