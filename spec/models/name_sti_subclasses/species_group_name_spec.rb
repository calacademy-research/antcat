# frozen_string_literal: true

require 'rails_helper'

describe SpeciesGroupName do
  describe "#genus_epithet" do
    let(:name) { described_class.new(name: 'Atta major') }

    specify { expect(name.genus_epithet).to eq 'Atta' }
  end

  describe "#species_epithet" do
    context 'when name does not contain a subgenus name' do
      let(:name) { described_class.new(name: 'Atta major') }

      specify { expect(name.species_epithet).to eq 'major' }
    end

    context 'when name contains a subgenus name' do
      let(:name) { described_class.new(name: 'Atta (Lasius) major') }

      specify { expect(name.species_epithet).to eq 'major' }
    end
  end
end
