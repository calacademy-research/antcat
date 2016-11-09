require 'spec_helper'

describe Family do
  let(:family) { create :family }

  describe "#statistics" do
    it "returns the statistics for each status of each rank" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      create :genus, subfamily: subfamily, tribe: tribe
      create :genus, subfamily: subfamily, status: 'homonym', tribe: tribe
      2.times { create :subfamily, fossil: true }

      expect(family.statistics).to eq(
        extant: {
          subfamilies: { 'valid' => 1 },
          tribes: { 'valid' => 1 },
          genera: { 'valid' => 1, 'homonym' => 1 }
        },
        fossil: {
          subfamilies: {'valid' => 2 }
        }
      )
    end
  end

  describe "#genera" do
    it "includes genera without subfamilies" do
      genus_without_subfamily = create_genus subfamily: nil
      genus_with_subfamily = create_genus subfamily: create_subfamily

      expect(family.genera).to eq [genus_without_subfamily]
    end
  end

  describe "#subfamilies" do
    it "includes all subfamilies" do
      subfamily = create_subfamily
      expect(family.subfamilies).to eq [subfamily]
    end
  end
end
