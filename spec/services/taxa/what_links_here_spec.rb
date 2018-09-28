require "spec_helper"

describe Taxa::WhatLinksHere do
  describe "#call" do
    let!(:taxon) { create :genus }

    context "when there are no references" do
      specify { expect(described_class[taxon]).to be_empty }
      specify { expect(described_class[taxon, predicate: true]).to be false }
    end

    describe "references in taxon fields" do
      context "when there are references in a subfamily" do
        specify do
          expect(described_class[taxon.subfamily]).to match_array [
            { table: 'taxa', field: :subfamily_id, id: taxon.id },
            { table: 'taxa', field: :subfamily_id, id: taxon.tribe.id }
          ]
        end

        specify { expect(described_class[taxon.subfamily, predicate: true]).to be true }
      end
    end

    describe "references in taxt" do
      context "when there are references in taxts" do
        let!(:other_taxon) { create :family, type_taxt: "{tax #{taxon.id}}" }

        specify do
          expect(described_class[taxon]).to match_array [
            { table: 'taxa', field: :type_taxt, id: other_taxon.id }
          ]
        end

        specify { expect(described_class[taxon, predicate: true]).to be true }
      end

      describe "when references in its own taxt" do
        it "doesn't consider this an external reference" do
          expect(described_class[taxon]).to be_empty
        end

        specify { expect(described_class[taxon, predicate: true]).to be false }
      end
    end

    describe "when reference in its authorship taxt" do
      before { taxon.protonym.authorship.update notes_taxt: "{tax #{taxon.id}}" }

      it "doesn't consider this an external reference" do
        expect(described_class[taxon]).to be_empty
      end

      specify { expect(described_class[taxon, predicate: true]).to be false }
    end

    describe "references as synonym" do
      let(:other_taxon) { create :family }

      context "when there are references" do
        before { create :synonym, junior_synonym: other_taxon, senior_synonym: taxon }

        specify do
          expect(described_class[taxon]).to match_array [
            { table: 'synonyms', field: :senior_synonym_id, id: other_taxon.id }
          ]

          expect(described_class[other_taxon]).to match_array [
            { table: 'synonyms', field: :junior_synonym_id, id: taxon.id }
          ]
        end

        specify { expect(described_class[taxon, predicate: true]).to be true }
        specify { expect(described_class[other_taxon, predicate: true]).to be true }
      end
    end
  end
end
