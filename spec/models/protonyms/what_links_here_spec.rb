# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::WhatLinksHere do
  subject(:what_links_here) { described_class.new(protonym) }

  context 'when there are no references' do
    let(:protonym) { create :protonym }

    specify { expect(what_links_here.all).to eq [] }
    specify { expect(what_links_here.any?).to eq false }
  end

  context 'when there are column references' do
    let!(:protonym) { create :protonym }
    let!(:taxon) { create :any_taxon, protonym: protonym }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('taxa', :protonym_id, taxon.id)
      ]
    end

    specify { expect(what_links_here.any?).to eq true }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.any_columns?).to eq true }
  end

  context 'when there are taxt references' do
    let!(:protonym) { create :protonym }

    describe "tag: `pro`" do
      let!(:history_item) { create :taxon_history_item, taxt: "{pro #{protonym.id}} in Lasius" }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('taxon_history_items', :taxt, history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end
  end
end
