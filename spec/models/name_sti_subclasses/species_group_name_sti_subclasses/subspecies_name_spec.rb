# frozen_string_literal: true

require 'rails_helper'

describe SubspeciesName do
  describe '#short_name' do
    it 'uses first letter only for genus and species epithets' do
      expect(described_class.new(name: 'Atta major minor').short_name).to eq 'A. m. minor'
      expect(described_class.new(name: 'Atta major var. minor').short_name).to eq 'A. m. var. minor'
    end
  end

  describe "name parts" do
    context 'when three name parts' do
      let(:name) { described_class.new(name: 'Atta major minor') }

      specify do
        expect(name.genus_epithet).to eq 'Atta'
        expect(name.species_epithet).to eq 'major'
        expect(name.subspecies_epithets).to eq 'minor'
      end
    end

    context 'when four name parts' do
      let(:name) { described_class.new(name: 'Acus major minor medium') }

      specify { expect(name.subspecies_epithets).to eq 'minor medium' }
    end
  end
end
