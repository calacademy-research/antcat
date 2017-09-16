require "spec_helper"

describe Taxa::WhatLinksHere do
  describe "#call" do
    let!(:atta) { create_genus 'Atta' }

    context "when there are no references" do
      specify { expect(described_class[atta]).to be_empty }
    end

    describe "references in taxon fields" do
      context "when there are references in a genus" do
        let!(:species) { create_species genus: atta }

        specify do
          expect(described_class[atta]).to match_array [
            { table: 'taxa', field: :genus_id, id: species.id }
          ]
        end
      end

      context "when there are references in a subfamily" do
        specify do
          expect(described_class[atta.subfamily]).to match_array [
            { table: 'taxa', field: :subfamily_id, id: atta.id },
            { table: 'taxa', field: :subfamily_id, id: atta.tribe.id }
          ]
        end
      end
    end

    describe "references in taxt" do
      context "when there are references in taxts" do
        let!(:eciton) { create_genus 'Eciton' }

        before { eciton.update_attribute :type_taxt, "{tax #{atta.id}}"  }

        specify do
          expect(described_class[atta]).to match_array [
            { table: 'taxa', field: :type_taxt, id: eciton.id }
          ]
        end
      end

      describe "when references in its own taxt" do
        before { atta.update_attribute :type_taxt, "{tax #{atta.id}}" }

        it "doesn't consider this an external reference" do
          expect(described_class[atta]).to be_empty
        end
      end
    end

    describe "when reference in its authorship taxt" do
      before { atta.protonym.authorship.update_attribute :notes_taxt, "{tax #{atta.id}}" }

      it "doesn't consider this an external reference" do
        expect(described_class[atta]).to be_empty
      end
    end

    describe "references as synonym" do
      let(:eciton) { create_genus 'Eciton' }

      context "when there are references" do
        before { Synonym.create! junior_synonym: eciton, senior_synonym: atta }

        specify do
          expect(described_class[atta]).to match_array [
            { table: 'synonyms', field: :senior_synonym_id, id: eciton.id }
          ]

          expect(described_class[eciton]).to match_array [
            { table: 'synonyms', field: :junior_synonym_id, id: atta.id }
          ]
        end
      end
    end
  end
end
