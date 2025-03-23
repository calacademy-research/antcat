# frozen_string_literal: true

require 'rails_helper'

describe NestedReference do
  describe 'relations' do
    it { is_expected.to belong_to(:nesting_reference).required }
  end

  describe "validations" do
    describe '#validate_nested_reference_doesnt_point_to_itself' do
      it "cannot point to itself" do
        reference = create :nested_reference

        reference.nesting_reference_id = reference.id
        expect(reference.valid?).to eq false
      end

      it "cannot point to something that points to itself" do
        inner_most = create :book_reference
        middle = create :nested_reference, nesting_reference: inner_most
        top = create :nested_reference, nesting_reference: middle
        middle.nesting_reference = top

        expect(middle.valid?).to eq false
        expect(middle.errors.where(:nesting_reference_id).map(&:message)).
          to include("can't point to itself")
      end
    end

    describe "#destroy validations" do
      let!(:reference) { create :nested_reference }

      it "is not be possible to delete a nesting reference" do
        nesting_reference = reference.reload.nesting_reference
        expect(nesting_reference.destroy).to eq false
        expect(nesting_reference.errors[:base].first).
          to eq "Cannot delete record because dependent nested references exist"
      end
    end
  end

  describe '#full_pagination' do
    let(:reference) { create :nested_reference }

    it 'includes pagination from the nesting reference' do
      expect(reference.full_pagination).to eq "#{reference.pagination} (#{reference.nesting_reference.pagination})"
    end
  end
end
