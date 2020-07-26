# frozen_string_literal: true

require 'rails_helper'

describe InfrasubspeciesName do
  describe "#subspecies_epithet" do
    let(:name) { described_class.new(name: 'Atta baba capa dapa') }

    specify { expect(name.subspecies_epithet).to eq 'capa' }
  end
end
