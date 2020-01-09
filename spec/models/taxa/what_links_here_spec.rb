require 'rails_helper'

describe Taxa::WhatLinksHere do
  subject(:what_links_here) { described_class.new(taxon) }

  let!(:taxon) { create :genus }

  context "when there are no references" do
    specify { expect(what_links_here.all).to be_empty }
    specify { expect(what_links_here.any?).to be false }
    specify { expect(what_links_here.columns).to be_empty }
    specify { expect(what_links_here.any_columns?).to be false }
    specify { expect(what_links_here.any_taxts?).to be false }
    specify { expect(what_links_here.taxts).to be_empty }
  end

  context 'when there are references in columns' do
    subject(:what_links_here) { described_class.new(taxon.subfamily) }

    specify do
      expect(what_links_here.all).to match_array [
        TableRef.new('taxa', :subfamily_id, taxon.id),
        TableRef.new('taxa', :subfamily_id, taxon.tribe.id)
      ]
      expect(what_links_here.all).to match_array what_links_here.columns
    end

    specify { expect(what_links_here.any?).to be true }
    specify { expect(what_links_here.any_taxts?).to be false }
    specify { expect(what_links_here.any_columns?).to be true }
  end

  describe "when there are references in taxts" do
    context "when references are not in its own taxt" do
      let!(:other_taxon) { create :family, type_taxt: "{tax #{taxon.id}}", type_taxon: create(:family) }

      specify do
        expect(what_links_here.all).to match_array [
          TableRef.new('taxa', :type_taxt, other_taxon.id)
        ]
        expect(what_links_here.all).to match_array what_links_here.taxts
      end

      specify { expect(what_links_here.any?).to be true }
      specify { expect(what_links_here.any_taxts?).to be true }
      specify { expect(what_links_here.any_columns?).to be false }
    end

    describe "when references are in its own taxt" do
      it "doesn't consider this an external reference" do
        expect(what_links_here.all).to be_empty
      end

      specify { expect(what_links_here.any?).to be false }
    end
  end

  describe "when reference in its authorship taxt" do
    before { taxon.protonym.authorship.update!(notes_taxt: "{tax #{taxon.id}}") }

    specify do
      expect(what_links_here.all).to match_array [
        TableRef.new('citations', :notes_taxt, taxon.protonym.authorship_id)
      ]
    end

    specify { expect(what_links_here.any?).to be true }
  end
end
