# frozen_string_literal: true

require 'rails_helper'

describe Taxa::WhatLinksHere::Columns do
  describe "#call" do
    subject(:what_links_here) { described_class.new(taxon) }

    let!(:taxon) { create :family }

    context "when taxon has non-taxt references" do
      let!(:homonym_replaced_by) { create :family, :homonym, homonym_replaced_by: taxon }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('taxa', :homonym_replaced_by_id, homonym_replaced_by.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
    end

    context "when taxon has no non-taxt references" do
      before do
        create :family, type_taxt: "{tax #{taxon.id}}", type_taxon: create(:family)
      end

      specify { expect(what_links_here.all).to eq [] }
      specify { expect(what_links_here.any?).to eq false }
    end
  end
end
