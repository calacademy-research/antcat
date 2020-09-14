# frozen_string_literal: true

require 'rails_helper'

describe InfrasubspeciesName do
  describe "#subspecies_epithet" do
    let(:name) { described_class.new(name: 'Atta baba capa dapa') }

    specify { expect(name.subspecies_epithet).to eq 'capa' }
  end

  describe '#short_name' do
    let(:name) { described_class.new(name: 'Atta baba capa dapa') }

    it 'uses first letter only for genus, species and subspecies epithets' do
      expect(name.short_name).to eq 'A. b. c. dapa'
    end
  end
end
