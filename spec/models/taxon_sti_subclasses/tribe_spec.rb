# frozen_string_literal: true

require 'rails_helper'

describe Tribe do
  describe 'relations' do
    it { is_expected.to have_many(:subtribes).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:genera).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:subfamily).required }
  end

  describe "#children" do
    it "returns the genera" do
      tribe = create :tribe

      genus = create :genus, tribe: tribe
      another_genus = create :genus, tribe: tribe

      expect(tribe.genera).to match_array [genus, another_genus]
      expect(tribe.children).to eq tribe.genera
    end
  end

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of tribes")
    end
  end
end
