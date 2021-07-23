# frozen_string_literal: true

require 'rails_helper'

# TODO: Test less. Here and in other `WhatLinksHere`s.

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
    let!(:history_item) { create :history_item, :junior_synonym_of, object_protonym: protonym }

    specify do
      expect(what_links_here.all).to match_array [
        WhatLinksHereItem.new('taxa',          :protonym_id,        taxon.id),
        WhatLinksHereItem.new('history_items', :object_protonym_id, history_item.id)
      ]
    end

    specify { expect(what_links_here.any?).to eq true }
    specify { expect(what_links_here.any_taxts?).to eq false }
    specify { expect(what_links_here.any_columns?).to eq true }
  end

  context 'when there are taxt references' do
    let!(:protonym) { create :protonym }

    describe "tag: `PRO_TAG`" do
      let(:taxt_tag) { Taxt.pro(protonym.id) }

      let!(:other_protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :taxt, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :etymology_taxt,                  other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      other_protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('history_items',       :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "tag: `PROAC_TAG`" do
      let(:taxt_tag) { Taxt.proac(protonym.id) }

      let!(:other_protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :taxt, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :etymology_taxt,                  other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      other_protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('history_items',       :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "tag: `PROTT_TAG`" do
      let(:taxt_tag) { Taxt.prott(protonym.id) }

      let!(:other_protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :taxt, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :etymology_taxt,                  other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      other_protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('history_items',       :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end

    describe "tag: `PROTTAC_TAG`" do
      let(:taxt_tag) { Taxt.prottac(protonym.id) }

      let!(:other_protonym) { create :protonym, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:history_item) { create :history_item, :taxt, :with_all_taxts, taxt_tag: taxt_tag }
      let!(:reference_section) { create :reference_section, :with_all_taxts, taxt_tag: taxt_tag }

      specify do
        expect(what_links_here.all).to match_array [
          WhatLinksHereItem.new('protonyms',           :etymology_taxt,                  other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :primary_type_information_taxt,   other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :secondary_type_information_taxt, other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :type_notes_taxt,                 other_protonym.id),
          WhatLinksHereItem.new('protonyms',           :notes_taxt,                      other_protonym.id),
          WhatLinksHereItem.new('reference_sections',  :title_taxt,                      reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :subtitle_taxt,                   reference_section.id),
          WhatLinksHereItem.new('reference_sections',  :references_taxt,                 reference_section.id),
          WhatLinksHereItem.new('history_items',       :taxt,                            history_item.id)
        ]
      end

      specify { expect(what_links_here.any?).to eq true }
      specify { expect(what_links_here.any_taxts?).to eq true }
      specify { expect(what_links_here.any_columns?).to eq false }
    end
  end
end
