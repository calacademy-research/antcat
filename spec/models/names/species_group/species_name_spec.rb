# frozen_string_literal: true

require 'rails_helper'

describe SpeciesName do
  describe '#name=' do
    specify do
      name = described_class.new(name: 'Lasius niger')

      expect(name.name).to eq 'Lasius niger'
      expect(name.epithet).to eq 'niger'
    end

    specify do
      name = described_class.new(name: 'Lasius (Austrolasius) niger')

      expect(name.name).to eq 'Lasius (Austrolasius) niger'
      expect(name.epithet).to eq 'niger'
    end
  end

  describe "name parts" do
    let(:species_name) { described_class.new(name: 'Atta major') }

    specify do
      expect(species_name.genus_epithet).to eq 'Atta'
      expect(species_name.species_epithet).to eq 'major'
    end
  end
end
