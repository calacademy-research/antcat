require 'spec_helper'

describe Subfamily do
  let(:subfamily) { create :subfamily }

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of subfamilies")
    end
  end

  it "can have tribes, which are its children" do
    tribe = create :tribe, subfamily: subfamily
    other_tribe = create :tribe, subfamily: subfamily

    expect(subfamily.tribes).to eq [tribe, other_tribe]
    expect(subfamily.tribes).to eq subfamily.children
  end
end
