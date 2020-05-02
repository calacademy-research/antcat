# frozen_string_literal: true

require 'rails_helper'

describe Taxa::WhatLinksHere do
  subject(:what_links_here) { described_class.new(taxon) }

  let!(:taxon) { create :genus }

  context "when there are no references" do
    specify { expect(what_links_here.all).to be_empty }
    specify { expect(what_links_here.any?).to eq false }
    specify { expect(what_links_here.columns).to be_empty }
    specify { expect(what_links_here.any_columns?).to eq false }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.taxts).to be_empty }
  end

  context 'when there are references in columns' do
    subject(:what_links_here) { described_class.new(taxon.subfamily) }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('taxa', :subfamily_id, taxon.id),
        WhatLinksHereItem.new('taxa', :subfamily_id, taxon.tribe.id)
      ]
      expect(what_links_here.all).to match_array what_links_here.columns
    end

    specify { expect(what_links_here.any?).to eq true }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.any_columns?).to eq true }
  end

  describe "when there are references in taxts" do
    context "when references are not in its own taxt" do
      let!(:other_taxon) { create :family, type_taxt: "{tax #{taxon.id}}", type_taxon: create(:family) }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('taxa', :type_taxt, other_taxon.id)
        ]
        expect(what_links_here.all).to match_array what_links_here.taxts
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "when references are in its own taxt" do
      it "doesn't consider this an external reference" do
        expect(what_links_here.all).to be_empty
      end

      specify { expect(what_links_here.any?).to eq false }
    end

    context "when 'taxac' tags are used" do
      let!(:other_taxon) { create :family, type_taxt: "{taxac #{taxon.id}}", type_taxon: create(:family) }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('taxa', :type_taxt, other_taxon.id)
        ]
        expect(what_links_here.taxts).to match_array what_links_here.taxts
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end
  end

  describe "when reference in its authorship taxt" do
    before { taxon.protonym.authorship.update!(notes_taxt: "{tax #{taxon.id}}") }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('citations', :notes_taxt, taxon.protonym.authorship_id)
      ]
    end

    specify { expect(what_links_here.any?).to eq true }
  end
end
