# frozen_string_literal: true

require 'rails_helper'

describe InfrasubspeciesName do
  describe "#subspecies_epithet" do
    let(:name) { described_class.new(name: 'Atta baba capa dapa') }

    specify { expect(name.subspecies_epithet).to eq 'capa' }
  end

  describe '#short_name' do
    it 'uses first letter only for genus, species and subspecies epithets' do
      expect(described_class.new(name: 'Atta baba capa dapa').short_name).to eq 'A. b. c. dapa'
    end
  end
end
