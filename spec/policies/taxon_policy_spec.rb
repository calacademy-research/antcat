# frozen_string_literal: true

require 'rails_helper'

describe TaxonPolicy do
  describe '#show_create_combination_button?' do
    %i[family subfamily tribe subtribe genus subgenus subspecies].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).show_create_combination_button?).to eq false
      end
    end

    %i[species].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).show_create_combination_button?).to eq true
      end
    end
  end

  describe '#allow_create_combination?' do
    let(:taxon) { build_stubbed :family }

    it 'calls `CreateCombinationPolicy`' do
      expect(CreateCombinationPolicy).to receive(:new).with(taxon).and_call_original
      described_class.new(taxon).allow_create_combination?
    end
  end

  describe '#show_create_combination_help_button?' do
    %i[family subfamily tribe subtribe genus subgenus].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).show_create_combination_help_button?).to eq false
      end
    end

    %i[species subspecies].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).show_create_combination_help_button?).to eq true
      end
    end
  end

  describe '#allow_create_obsolete_combination?' do
    context 'when taxon is valid' do
      %i[family subfamily tribe subtribe genus subgenus subspecies].each do |rank|
        specify do
          taxon = build_stubbed rank
          expect(described_class.new(taxon).allow_create_obsolete_combination?).to eq false
        end
      end

      %i[species].each do |rank|
        specify do
          taxon = build_stubbed rank
          expect(described_class.new(taxon).allow_create_obsolete_combination?).to eq true
        end
      end
    end

    context 'when taxon is invalid' do
      %i[family subfamily tribe subtribe genus subgenus subspecies species].each do |rank|
        specify do
          taxon = build_stubbed rank
          allow(taxon).to receive(:valid_taxon?).and_return(false)
          expect(described_class.new(taxon).allow_create_obsolete_combination?).to eq false
        end
      end
    end

    context 'when species has no genus' do
      let(:taxon) { build_stubbed :species, genus: nil }

      specify do
        expect(described_class.new(taxon).allow_create_obsolete_combination?).to eq false
      end
    end
  end

  describe '#allow_force_change_parent?' do
    %i[family subfamily tribe subgenus].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).allow_force_change_parent?).to eq false
      end
    end

    %i[genus species subspecies].each do |rank|
      specify do
        taxon = build_stubbed rank
        expect(described_class.new(taxon).allow_force_change_parent?).to eq true
      end
    end
  end
end
