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

  describe "#subfamilies" do
    let!(:subfamily) { create :subfamily }

    it "includes all subfamilies" do
      expect(family.subfamilies).to eq [subfamily]
    end
  end
end
