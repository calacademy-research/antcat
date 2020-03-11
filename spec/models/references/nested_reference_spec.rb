require 'rails_helper'

describe NestedReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :pagination }
  it { is_expected.to validate_presence_of(:nesting_reference).with_message("does not exist") }

  describe "validations" do
    it "cannot point to itself" do
      reference = create :nested_reference

      reference.nesting_reference_id = reference.id
      expect(reference).not_to be_valid
    end

    it "cannot point to something that points to itself" do
      inner_most = create :book_reference
      middle = create :nested_reference, nesting_reference: inner_most
      top = create :nested_reference, nesting_reference: middle
      middle.nesting_reference = top

      expect(middle).not_to be_valid
    end
  end

  describe "#destroy" do
    let!(:reference) { create :nested_reference }

    it "is not be possible to delete a nestee" do
      nesting_reference = reference.reload.nesting_reference
      expect(nesting_reference.destroy).to be false
      expect(nesting_reference.errors[:base].first).
        to eq "Cannot delete record because dependent nestees exist"
    end
  end
end
