# frozen_string_literal: true

require 'rails_helper'

describe SubspeciesName do
  describe "#subspecies_epithet" do
    let(:name) { described_class.new(name: 'Atta baba capa') }

    specify { expect(name.subspecies_epithet).to eq 'capa' }
  end

  describe '#short_name' do
    it 'uses first letter only for genus and species epithets' do
      expect(described_class.new(name: 'Atta baba capa').short_name).to eq 'A. b. capa'
    end
  end
end
