# frozen_string_literal: true

require 'rails_helper'

describe SubgenusName do
  describe 'callbacks' do
    describe '#set_epithet' do
      let!(:name) { described_class.new(name: 'Lasius (Austrolasius)') }

      it 'uses the subgenus part of the name for the epithet' do
        expect(name.name).to eq 'Lasius (Austrolasius)'
        expect(name.epithet).to eq 'Austrolasius'
      end
    end
  end
end
