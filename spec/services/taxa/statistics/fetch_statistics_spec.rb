# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Statistics::FetchStatistics do
  describe "#call" do
    context 'when taxon has no children' do
      let(:taxon) { create :family }

      specify { expect(described_class[taxon]).to eq({}) }
    end

    context "when there are extant and fossil children" do
      let(:family) { create :family }

      before do
        create :subfamily
        create :subfamily, :fossil
      end

      it "separates extant and fossil children in groups" do
        expect(described_class[family]).to eq(
          extant: {
            subfamilies: { 'valid' => 1 }
          },
          fossil: {
            subfamilies: { 'valid' => 1 }
          }
        )
      end
    end

    context "when family with children" do
      let(:family) { create :family }

      before do
        subfamily = create :subfamily
        tribe = create :tribe, subfamily: subfamily
        genus = create :genus, :homonym, subfamily: subfamily, tribe: tribe
        2.times { create :subfamily, :fossil }
        create :species, genus: genus
      end

      specify do
        expect(described_class[family]).to eq(
          extant: {
            subfamilies: { 'valid' => 1 },
            tribes: { 'valid' => 1 },
            genera: { 'homonym' => 1 },
            species: { 'valid' => 1 }
          },
          fossil: {
            subfamilies: { 'valid' => 2 }
          }
        )
      end
    end

    context "when subfamily with children" do
      let(:subfamily) { create :subfamily }

      before do
        create :tribe, subfamily: subfamily
        create :genus, :synonym, subfamily: subfamily
        genus = create :genus, subfamily: subfamily
        2.times { create :species, genus: genus, subfamily: subfamily }
      end

      specify do
        expect(described_class[subfamily]).to eq extant: {
          tribes: { 'valid' => 1 },
          genera: { 'valid' => 1, 'synonym' => 1 },
          species: { 'valid' => 2 }
        }
      end
    end

    context "when tribe with children" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      specify do
        genus = create :genus, tribe: tribe
        create :species, genus: genus
        create :species, :synonym, genus: genus

        expect(described_class[tribe]).to eq extant: {
          genera: { "valid" => 1 },
          species: { "synonym" => 1, "valid" => 1 }
        }
      end
    end

    context "when genus with children" do
      let(:genus) { create :genus }

      before do
        species = create :species, genus: genus
        2.times { create :subspecies, species: species, genus: genus }
      end

      specify do
        expect(described_class[genus]).to eq extant: {
          species: { 'valid' => 1 },
          subspecies: { 'valid' => 2 }
        }
      end
    end

    context "when species with children" do
      let(:species) { create :species }

      before do
        create :subspecies, species: species
      end

      specify do
        expect(described_class[species]).to eq extant: {
          subspecies: { 'valid' => 1 }
        }
      end
    end
  end
end
