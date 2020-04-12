# frozen_string_literal: true

require 'rails_helper'

describe SpeciesName do
  describe "name parts" do
    let(:name) { described_class.new(name: 'Atta major') }

    specify do
      expect(name.genus_epithet).to eq 'Atta'
      expect(name.species_epithet).to eq 'major'
    end
  end
end
