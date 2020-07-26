# frozen_string_literal: true

require 'rails_helper'

describe SubspeciesName do
  describe "#subspecies_epithet" do
    let(:name) { described_class.new(name: 'Atta baba capa') }

    specify { expect(name.subspecies_epithet).to eq 'capa' }
  end

  describe "#subspecies_epithets" do
    context 'when three name parts' do
      let(:name) { described_class.new(name: 'Atta baba capa') }

      specify { expect(name.subspecies_epithets).to eq 'capa' }
    end

    # TODO: Remove now that there are no broken quadrinomials.
    context 'when four name parts' do
      let(:name) { described_class.new(name: 'Atta baba capa dapa') }

      specify { expect(name.subspecies_epithets).to eq 'capa dapa' }
    end
  end

  describe '#short_name' do
    it 'uses first letter only for genus and species epithets' do
      expect(described_class.new(name: 'Atta baba capa').short_name).to eq 'A. b. capa'
    end
  end
end
