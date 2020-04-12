# frozen_string_literal: true

require 'rails_helper'

describe SubspeciesName do
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
