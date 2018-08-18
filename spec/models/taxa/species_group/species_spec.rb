require 'spec_helper'

describe Species do
  it "can have subspecies, which are its children" do
    species = create_species
    robusta = create_subspecies species: species
    saltensis = create_subspecies species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end

  describe "#statistics" do
    let(:species) { create_species }

    context "when 0 children" do
      specify { expect(species.statistics).to eq({}) }
    end

    context "when 1 valid subspecies" do
      before { create_subspecies species: species }

      specify do
        expect(species.statistics).to eq extant: {
          subspecies: { 'valid' => 1 }
        }
      end
    end

    context "when there are extant and fossil subspecies" do
      before do
        create_subspecies species: species
        create_subspecies species: species, fossil: true
      end

      specify do
        expect(species.statistics).to eq(
          extant: { subspecies: { 'valid' => 1 } },
          fossil: { subspecies: { 'valid' => 1 } }
        )
      end
    end

    context "when 1 valid subspecies and 2 synonyms" do
      before do
        create_subspecies species: species
        2.times { create_subspecies species: species, status: Status::SYNONYM }
      end

      specify do
        expect(species.statistics).to eq extant: {
          subspecies: { 'valid' => 1, 'synonym' => 2 }
        }
      end
    end
  end

  describe "#siblings" do
    let(:genus) { create :genus }
    let(:species) { create_species genus: genus }
    let(:another_species) { create_species genus: genus }

    it "returns itself and its genus's species" do
      expect(species.siblings).to match_array [species, another_species]
    end
  end
end
