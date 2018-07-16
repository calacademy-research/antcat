require 'spec_helper'

describe Family do
  let(:family) { create :family }

  describe "#statistics" do
    before do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      create :genus, subfamily: subfamily, tribe: tribe
      create :genus, :homonym, subfamily: subfamily, tribe: tribe
      2.times { create :subfamily, fossil: true }
    end

    it "returns the statistics for each status of each rank" do
      expect(family.statistics).to eq(
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

  describe "#genera" do
    let!(:genus_without_subfamily) { create_genus subfamily: nil }

    before { create_genus subfamily: create_subfamily } # genus_with_subfamily

    it "includes genera without subfamilies" do
      expect(family.genera).to eq [genus_without_subfamily]
    end
  end

  describe "#subfamilies" do
    let!(:subfamily) { create_subfamily }

    it "includes all subfamilies" do
      expect(family.subfamilies).to eq [subfamily]
    end
  end
end
