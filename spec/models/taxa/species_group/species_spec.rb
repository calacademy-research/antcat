require 'spec_helper'

describe Species do
  it "can have subspecies, which are its children" do
    species = create :species
    robusta = create :subspecies, species: species
    saltensis = create :subspecies, species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end

  describe "#statistics" do
    let(:species) { create :species }

    context "when 0 children" do
      specify { expect(species.statistics).to eq({}) }
    end

    context "when 1 valid subspecies" do
      before { create :subspecies, species: species }

      specify do
        expect(species.statistics).to eq extant: {
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
        expect(species.statistics).to eq(
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
        expect(species.statistics).to eq extant: {
          subspecies: { 'valid' => 1, 'synonym' => 2 }
        }
      end
    end
  end
end
