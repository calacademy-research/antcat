# frozen_string_literal: true

require 'rails_helper'

describe Infrasubspecies do
  describe 'relations' do
    describe 'required `belongs_to`' do
      subject(:taxon) { create :infrasubspecies }

      it { is_expected.to belong_to(:genus).required }
      it { is_expected.to belong_to(:species).required }
      it { is_expected.to belong_to(:subspecies).required }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_absence_of(:family_id) }
    it { is_expected.to validate_absence_of(:tribe_id) }
    it { is_expected.to validate_absence_of(:subgenus_id) }

    describe '#rank validations' do
      subject(:taxon) { create :infrasubspecies }

      it { is_expected.not_to allow_value(Status::VALID).for(:status).with_message("is not allowed for rank.") }
    end
  end

  describe "#parent" do
    let(:taxon) { create :infrasubspecies }

    specify { expect(taxon.parent).to eq taxon.subspecies }
  end

  describe "#parent=" do
    let(:infrasubspecies) { create :infrasubspecies }
    let(:new_parent) { create :subspecies }

    it "sets all the parent fields" do
      infrasubspecies.parent = new_parent

      expect(infrasubspecies.subspecies).to eq new_parent
      expect(infrasubspecies.species).to eq new_parent.species
      expect(infrasubspecies.genus).to eq new_parent.genus
      expect(infrasubspecies.subfamily).to eq new_parent.subfamily
    end

    context 'when new parent is not a subspecies' do
      let(:new_parent) { create :family }

      specify { expect { infrasubspecies.parent = new_parent }.to raise_error(Taxa::InvalidParent) }
    end
  end

  describe "#update_parent" do
    let(:taxon) { described_class.new }

    specify { expect { taxon.update_parent(nil) }.to raise_error("cannot update parent of infrasubspecies") }
  end
end
