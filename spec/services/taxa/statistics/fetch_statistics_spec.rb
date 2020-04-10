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

    context "when family" do
      let(:family) { create :family }

      before do
        subfamily = create :subfamily
        tribe = create :tribe, subfamily: subfamily
        create :genus, :homonym, subfamily: subfamily, tribe: tribe
        2.times { create :subfamily, :fossil }
      end

      it "returns the statistics for each status of each rank" do
        expect(described_class[family]).to eq(
          extant: {
            subfamilies: { 'valid' => 1 },
            tribes: { 'valid' => 1 },
            genera: { 'homonym' => 1 }
          },
          fossil: {
            subfamilies: { 'valid' => 2 }
          }
        )
      end
    end

    context "when subfamily" do
      let(:subfamily) { create :subfamily }

      context "when 1 valid genus, 2 synonyms, and 2 valid species" do
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
    end

    context "when tribe" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      it "includes the number of genera and species" do
        genus = create :genus, tribe: tribe
        create :species, genus: genus
        create :species, :synonym, genus: genus

        expect(described_class[tribe]).to eq extant: {
          genera: { "valid" => 1 },
          species: { "synonym" => 1, "valid" => 1 }
        }
      end
    end

    context "when genus" do
      let(:genus) { create :genus }

      context "when 1 valid species" do
        before { create :species, genus: genus }

        specify do
          expect(described_class[genus]).to eq extant: { species: { 'valid' => 1 } }
        end
      end

      context "when there are species and subspecies" do
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
    end

    context "when species" do
      let(:species) { create :species }

      context "when 1 valid subspecies" do
        before { create :subspecies, species: species }

        specify do
          expect(described_class[species]).to eq extant: {
            subspecies: { 'valid' => 1 }
          }
        end
      end
    end
  end
end
