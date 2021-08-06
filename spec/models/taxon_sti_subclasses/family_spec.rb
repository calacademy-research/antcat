# frozen_string_literal: true

require 'rails_helper'

describe Family do
  describe 'validations' do
    it { is_expected.to validate_absence_of(:family_id) }
    it { is_expected.to validate_absence_of(:subfamily_id) }
    it { is_expected.to validate_absence_of(:tribe_id) }
    it { is_expected.to validate_absence_of(:genus_id) }
    it { is_expected.to validate_absence_of(:subgenus_id) }
    it { is_expected.to validate_absence_of(:species_id) }
    it { is_expected.to validate_absence_of(:subspecies_id) }
  end

  describe "#parent" do
    let(:family) { create :family }

    specify { expect(family.parent).to eq nil }
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
    let(:family) { create :family }
    let!(:subfamily) { create :subfamily }

    it "includes all subfamilies" do
      expect(family.subfamilies).to eq [subfamily]
    end
  end
end
