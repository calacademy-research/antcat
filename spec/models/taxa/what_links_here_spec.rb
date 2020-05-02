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

  context 'when there are column references' do
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

  context "when there are taxt references" do
    describe "tag: `tax`" do
      let!(:other_taxon) { create :family, type_taxt: "{tax #{taxon.id}}", type_taxon: create(:family) }

      before do
        other_taxon.protonym.authorship.update!(notes_taxt: "{tax #{taxon.id}}")
      end

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('taxa',      :type_taxt,  other_taxon.id),
          WhatLinksHereItem.new('citations', :notes_taxt, other_taxon.protonym.authorship_id)
        ]
        expect(what_links_here.all).to match_array what_links_here.taxts
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "tag: `taxac`" do
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
end
