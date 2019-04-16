require 'spec_helper'

describe Family do
  let(:family) { create :family }

  describe "#parent" do
    specify { expect(family.parent).to be_nil }
  end

  describe "#parent=" do
    specify do
      expect { described_class.new.parent = nil }.to raise_error("cannot update parent of families")
    end
  end

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of families")
    end
  end

  describe "#genera" do
    let!(:genus_without_subfamily) { create :genus, subfamily: nil }

    before { create :genus, subfamily: create(:subfamily) }

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
