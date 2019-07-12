require 'spec_helper'

describe Taxa::Statistics::FetchStatistics do
  describe "#call" do
    context "when family" do
      let(:family) { create :family }

      before do
        subfamily = create :subfamily
        tribe = create :tribe, subfamily: subfamily
        homonym_replaced_by = create :genus, subfamily: subfamily, tribe: tribe
        create :genus, :homonym, homonym_replaced_by: homonym_replaced_by, subfamily: subfamily, tribe: tribe
        2.times { create :subfamily, fossil: true }
      end

      it "returns the statistics for each status of each rank" do
        expect(described_class[family]).to eq(
          extant: {
            subfamilies: { 'valid' => 1 },
            tribes: { 'valid' => 1 },
            genera: { 'valid' => 1, 'homonym' => 1 }
          },
          fossil: {
            subfamilies: { 'valid' => 2 }
          }
        )
      end
    end

    context "when subfamily" do
      let(:subfamily) { create :subfamily }

      context "when 0 children" do
        specify { expect(described_class[subfamily]).to eq({}) }
      end

      context "when 1 valid genus and 2 synonyms" do
        before do
          create :genus, subfamily: subfamily
          2.times { create :genus, :synonym, subfamily: subfamily }
        end

        specify do
          expect(described_class[subfamily]).to eq extant: {
            genera: { 'valid' => 1, 'synonym' => 2 }
          }
        end
      end

      context "when 1 valid genus with 2 valid species" do
        before do
          genus = create :genus, subfamily: subfamily
          2.times { create :species, genus: genus, subfamily: subfamily }
        end

        specify do
          expect(described_class[subfamily]).to eq extant: {
            genera: { 'valid' => 1 },
            species: { 'valid' => 2 }
          }
        end
      end

      context "when 1 valid genus with 2 valid species, one of which has a subspecies" do
        before do
          genus = create :genus, subfamily: subfamily
          create :species, genus: genus
          create :subspecies, genus: genus, species: create(:species, genus: genus)
        end

        specify do
          expect(described_class[subfamily]).to eq extant: {
            genera: { 'valid' => 1 },
            species: { 'valid' => 2 },
            subspecies: { 'valid' => 1 }
          }
        end
      end

      context "when there are extinct genera, species and subspecies" do
        before do
          genus = create :genus, subfamily: subfamily
          create :genus, subfamily: subfamily, fossil: true
          create :species, genus: genus
          create :species, genus: genus, fossil: true
          create :subspecies, genus: genus, species: create(:species, genus: genus)
          create :subspecies, genus: genus, species: create(:species, genus: genus), fossil: true
        end

        it "differentiates between extinct genera, species and subspecies" do
          expect(described_class[subfamily]).to eq(
            extant: {
              genera: { 'valid' => 1 },
              species: { 'valid' => 3 },
              subspecies: { 'valid' => 1 }
            },
            fossil: {
              genera: { 'valid' => 1 },
              species: { 'valid' => 1 },
              subspecies: { 'valid' => 1 }
            }
          )
        end
      end

      it "can count tribes" do
        create :tribe, subfamily: subfamily
        expect(described_class[subfamily]).to eq extant: { tribes: { 'valid' => 1 } }
      end
    end

    context "when tribe" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      it "includes the number of genera" do
        create :genus, tribe: tribe
        expect(described_class[tribe]).to eq extant: { genera: { 'valid' => 1 } }
      end

      it "includes the number of species" do
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

      context "when 0 children" do
        specify { expect(described_class[genus]).to eq({}) }
      end

      context "when 1 valid species" do
        before { create :species, genus: genus }

        specify do
          expect(described_class[genus]).to eq extant: { species: { 'valid' => 1 } }
        end
      end

      context "when there are original combinations" do
        before do
          create :species, genus: genus
          create :species, :original_combination, genus: genus
        end

        it "ignores the original combinations" do
          expect(described_class[genus]).to eq extant: { species: { 'valid' => 1 } }
        end
      end

      context "when 1 valid species and 2 synonyms" do
        before do
          create :species, genus: genus
          2.times { create :species, :synonym, genus: genus }
        end

        specify do
          expect(described_class[genus]).to eq extant: {
            species: { 'valid' => 1, 'synonym' => 2 }
          }
        end
      end

      context "when 1 valid species with 2 valid subspecies" do
        before do
          species = create :species, genus: genus
          2.times { create :subspecies, species: species, genus: genus }
        end

        specify do
          expect(described_class[genus]).to eq extant: {
            species: { 'valid' => 1 }, subspecies: { 'valid' => 2 }
          }
        end
      end

      context "when there are extinct species and subspecies" do
        before do
          species = create :species, genus: genus
          fossil_species = create :species, genus: genus, fossil: true
          create :subspecies, genus: genus, species: species, fossil: true
          create :subspecies, genus: genus, species: species
          create :subspecies, genus: genus, species: fossil_species, fossil: true
        end

        it "can differentiate extinct species and subspecies" do
          expect(described_class[genus]).to eq(
            extant: {
              species: { 'valid' => 1 },
              subspecies: { 'valid' => 1 }
            },
            fossil: {
              species: { 'valid' => 1 },
              subspecies: { 'valid' => 2 }
            }
          )
        end
      end
    end

    context "when subgenus" do
      let(:subgenus) { create :subgenus }

      it "has none" do
        expect(described_class[subgenus]).to be_nil
      end
    end

    context "when species" do
      let(:species) { create :species }

      context "when 0 children" do
        specify { expect(described_class[species]).to eq({}) }
      end

      context "when 1 valid subspecies" do
        before { create :subspecies, species: species }

        specify do
          expect(described_class[species]).to eq extant: {
            subspecies: { 'valid' => 1 }
          }
        end
      end

      context "when there are extant and fossil subspecies" do
        before do
          create :subspecies, species: species
          create :subspecies, species: species, fossil: true
        end

        specify do
          expect(described_class[species]).to eq(
            extant: { subspecies: { 'valid' => 1 } },
            fossil: { subspecies: { 'valid' => 1 } }
          )
        end
      end

      context "when 1 valid subspecies and 2 synonyms" do
        before do
          create :subspecies, species: species
          2.times { create :subspecies, :synonym, species: species }
        end

        specify do
          expect(described_class[species]).to eq extant: {
            subspecies: { 'valid' => 1, 'synonym' => 2 }
          }
        end
      end
    end

    context "when subspecies" do
      it "has no statistics" do
        expect(described_class[Subspecies.new]).to be_nil
      end
    end
  end
end
