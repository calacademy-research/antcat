require 'rails_helper'

describe Taxa::WhatLinksHere do
  describe "#call" do
    let!(:taxon) { create :genus }

    context "when there are no references" do
      specify { expect(described_class[taxon]).to be_empty }
      specify { expect(described_class[taxon, predicate: true]).to be false }
    end

    context 'when there are references in relations' do
      context "when there are references in a subfamily" do
        specify do
          expect(described_class[taxon.subfamily]).to match_array [
            TableRef.new('taxa', :subfamily_id, taxon.id),
            TableRef.new('taxa', :subfamily_id, taxon.tribe.id)
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
            TableRef.new('taxa', :type_taxt, other_taxon.id)
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
      before { taxon.protonym.authorship.update!(notes_taxt: "{tax #{taxon.id}}") }

      specify do
        expect(described_class[taxon]).to match_array [
          TableRef.new('citations', :notes_taxt, taxon.protonym.authorship_id)
        ]
      end

      specify { expect(described_class[taxon, predicate: true]).to be true }
    end
  end
end
