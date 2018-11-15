require 'spec_helper'

describe Family do
  let(:family) { create :family }

  describe "#parent" do
    specify { expect(family.parent).to be_nil }
  end

  describe "#genera" do
    let!(:genus_without_subfamily) { create :genus, subfamily: nil }

    before { create :genus, subfamily: create(:subfamily) } # genus_with_subfamily

    it "includes genera without subfamilies" do
      expect(family.genera).to eq [genus_without_subfamily]
    end
  end

  describe "#subfamilies" do
    let!(:subfamily) { create :subfamily }

    it "includes all subfamilies" do
      expect(family.subfamilies).to eq [subfamily]
    end
  end
end
