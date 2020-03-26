# frozen_string_literal: true

require 'rails_helper'

describe Infrasubspecies do
  describe 'validations' do
    subject(:taxon) { create :infrasubspecies }

    it { is_expected.to validate_presence_of :genus }
    it { is_expected.to validate_presence_of :species }
    it { is_expected.to validate_presence_of :subspecies }
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
      expect(infrasubspecies.subgenus).to eq new_parent.subgenus
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

  describe "#children" do
    let(:taxon) { described_class.new }

    specify { expect(taxon.children).to eq Taxon.none }
  end
end
