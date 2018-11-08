require 'spec_helper'

describe Subfamily do
  let(:subfamily) { create :subfamily }

  it "can have tribes, which are its children" do
    tribe = create :tribe, subfamily: subfamily
    other_tribe = create :tribe, subfamily: subfamily

    expect(subfamily.tribes).to eq [tribe, other_tribe]
    expect(subfamily.tribes).to eq subfamily.children
  end
end
