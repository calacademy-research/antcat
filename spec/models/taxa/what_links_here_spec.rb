# frozen_string_literal: true

require 'rails_helper'

describe Taxa::WhatLinksHere do
  subject(:what_links_here) { described_class.new(taxon) }

  context "when there are no references" do
    let(:taxon) { create :any_taxon }

    specify { expect(what_links_here.all).to be_empty }
    specify { expect(what_links_here.any?).to eq false }
    specify { expect(what_links_here.columns).to be_empty }
    specify { expect(what_links_here.any_columns?).to eq false }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.taxts).to be_empty }
  end

  context 'when there are column references' do
    let(:taxon) { create :genus }
    let!(:species) { create :species, genus: taxon }
    let!(:type_name) { create :type_name, :by_subsequent_designation_of, taxon: taxon }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('taxa',       :genus_id,       species.id),
        WhatLinksHereItem.new('type_names', :taxon_id,       type_name.id)
      ]
    end

    specify { expect(what_links_here.any?).to eq true }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.any_columns?).to eq true }
  end

  context "when there are taxt references" do
    let(:taxon) { create :any_taxon }

    describe "tag: `tax`" do
      let(:taxt_tag) { "{tax #{taxon.id}}" }

      let!(:protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('taxon_history_items', :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "tag: `taxac`" do
      let(:taxt_tag) { "{taxac #{taxon.id}}" }

      let!(:protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('taxon_history_items', :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end
  end
end
