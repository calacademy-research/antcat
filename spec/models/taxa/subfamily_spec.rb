require 'spec_helper'

describe Subfamily do
  let(:subfamily) { create :subfamily }

  it "can have tribes, which are its children" do
    tribe = create :tribe, subfamily: subfamily
    other_tribe = create :tribe, subfamily: subfamily

    expect(subfamily.tribes).to eq [tribe, other_tribe]
    expect(subfamily.tribes).to eq subfamily.children
  end

  describe "#statistics" do
    context "when 0 children" do
      specify { expect(subfamily.statistics).to eq({}) }
    end

    context "when 1 valid genus" do
      before { create :genus, subfamily: subfamily }

      specify do
        expect(subfamily.statistics).to eq extant: { genera: { 'valid' => 1 } }
      end
    end

    context "when 1 valid genus and 2 synonyms" do
      before do
        create :genus, subfamily: subfamily
        2.times { create :genus, :synonym, subfamily: subfamily }
      end

      specify do
        expect(subfamily.statistics).to eq extant: {
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
        expect(subfamily.statistics).to eq extant: {
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
        expect(subfamily.statistics).to eq extant: {
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
        expect(subfamily.statistics).to eq(
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
      expect(subfamily.statistics).to eq extant: { tribes: { 'valid' => 1 } }
    end
  end
end
