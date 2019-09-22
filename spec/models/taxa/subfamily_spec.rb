require 'spec_helper'

describe Subfamily do
  describe 'relations' do
    it { is_expected.to have_many(:tribes).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:genera).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:subspecies).dependent(:restrict_with_error) }
  end

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of subfamilies")
    end
  end

  it "can have tribes, which are its children" do
    subfamily = create :subfamily
    tribe = create :tribe, subfamily: subfamily
    other_tribe = create :tribe, subfamily: subfamily

    expect(subfamily.tribes).to eq [tribe, other_tribe]
    expect(subfamily.tribes).to eq subfamily.children
  end
end
