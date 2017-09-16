require "spec_helper"

describe Taxa::WhatLinksHere do
  describe "#call" do
    let!(:atta) { create_genus 'Atta' }
    subject { described_class.new(atta) }

    it "has no references, if alone" do
      expect(subject.call.size).to eq 0
    end

    describe "references in Taxon fields" do
      it "has a reference if it's a taxon's genus" do
        species = create_species genus: atta
        expect(subject.call).to match_array [
          { table: 'taxa', field: :genus_id, id: species.id }
        ]
      end

      it "has a reference if it's a taxon's subfamily" do
        subject = described_class.new(atta.subfamily)
        expect(subject.call).to match_array [
          { table: 'taxa', field: :subfamily_id, id: atta.id },
          { table: 'taxa', field: :subfamily_id, id: atta.tribe.id }
        ]
      end
    end

    describe "references in taxt" do
      it "returns references in taxt" do
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"

        expect(subject.call).to match_array [
          { table: 'taxa', field: :type_taxt, id: eciton.id }
        ]
      end

      it "doesn't return references in its own taxt" do
        atta.update_attribute :type_taxt, "{tax #{atta.id}}"
        expect(subject.call).to be_empty
      end
    end

    describe "Reference in its authorship taxt" do
      before { atta.protonym.authorship.update_attribute :notes_taxt, "{tax #{atta.id}}" }

      it "doesn't consider this an external reference" do
        expect(subject.call).to be_empty
      end
    end

    describe "references as synonym" do
      let(:eciton) { create_genus 'Eciton' }

      before { Synonym.create! junior_synonym: eciton, senior_synonym: atta }

      specify do
        subject = described_class.new(atta)
        expect(subject.call).to match_array [
          { table: 'synonyms', field: :senior_synonym_id, id: eciton.id }
        ]

        subject = described_class.new(eciton)
        expect(subject.call).to match_array [
          { table: 'synonyms', field: :junior_synonym_id, id: atta.id }
        ]
      end
    end
  end
end
