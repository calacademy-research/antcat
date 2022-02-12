# frozen_string_literal: true

require 'rails_helper'

describe WhatLinksHereItem do
  describe '#detax' do
    context 'when `what_links_here_item` is a taxt item' do
      let!(:history_item) { create :history_item, :taxt }
      let!(:what_links_here_item) { described_class.new('history_items', :taxt, history_item.id) }

      specify { expect(what_links_here_item.detax).to eq Detax[history_item.to_taxt] }
    end

    context 'when `what_links_here_item` is a relational history item' do
      let!(:history_item) { create :history_item, :junior_synonym_of }
      let!(:what_links_here_item) { described_class.new('history_items', :object_protonym_id, history_item.id) }

      specify { expect(what_links_here_item.detax).to eq Detax[history_item.to_taxt] }
    end

    context 'when `what_links_here_item` is not a taxt item' do
      let!(:what_links_here_item) { described_class.new('taxa', :species_id, 999) }

      specify { expect(what_links_here_item.detax).to eq nil }
    end
  end

  describe '#taxt?' do
    context 'when `what_links_here_item` is a taxt item' do
      specify do
        expect(described_class.new('history_items', :taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :primary_type_information_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :secondary_type_information_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :type_notes_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :notes_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :references_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :subtitle_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :title_taxt, 999).taxt?).to eq true
      end
    end

    context 'when `what_links_here_item` is not a taxt item' do
      specify do
        Taxa::WhatLinksHere::REFERENCING_COLUMNS.each do |(_model, field)|
          expect(described_class.new('taxa', field, 999).taxt?).to eq false
        end
      end
    end
  end

  describe '#owner' do
    subject(:what_links_here_item) { described_class.new(table, "_field", id) }

    let(:id) { object.id }

    context "when table is `citations`" do
      let(:table) { "citations" }
      let(:object) { create(:protonym).authorship }

      specify { expect(what_links_here_item.owner).to eq object.protonym }
    end

    context "when table is `history_items`" do
      let(:table) { "history_items" }
      let!(:object) { create :history_item, :taxt }

      specify { expect(what_links_here_item.owner).to eq object.protonym }
    end

    context "when table is `protonyms`" do
      let(:table) { "protonyms" }
      let!(:object) { create :protonym }

      specify { expect(what_links_here_item.owner).to eq object }
    end

    context "when table is `reference_sections`" do
      let(:table) { "reference_sections" }
      let!(:object) { create :reference_section }

      specify { expect(what_links_here_item.owner).to eq object.taxon }
    end

    context "when table is `references`" do
      let(:table) { "references" }
      let!(:object) { create :any_reference }

      specify { expect(what_links_here_item.owner).to eq object }
    end

    context "when table is `taxa`" do
      let(:table) { "taxa" }
      let!(:object) { create :any_taxon }

      specify { expect(what_links_here_item.owner).to eq object }
    end

    context "when table is `type_names`" do
      let(:table) { "type_names" }
      let!(:object) { create :type_name }

      specify { expect(what_links_here_item.owner).to eq object.protonym }
    end
  end
end
