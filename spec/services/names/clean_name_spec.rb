# frozen_string_literal: true

require 'rails_helper'

describe Names::CleanName do
  describe '#call' do
    it 'capitalizes the first letter, downcasing the rest' do
      expect(described_class['formica Subspinosa']).to eq 'Formica subspinosa'
    end

    context 'when a subgenus name' do
      it 'considers the subgenus part of the name as the part to keep' do
        expect(described_class['Formica (Forelophilus)']).to eq 'Forelophilus'
      end
    end

    context 'when not a subgenus name' do
      it 'removes words in parentheses' do
        expect(described_class['Formica (Hypochira) subspinosa']).to eq 'Formica subspinosa'
      end
    end

    it 'removes known ranks abbreviations (full words, case insensitive)' do
      expect(described_class['Formica fusca var. flavus']).to eq 'Formica fusca flavus'
      expect(described_class['Formica fusca Var. flavus']).to eq 'Formica fusca flavus'
      expect(described_class['Formica fusca avar. flavus']).to eq 'Formica fusca avar. flavus'
    end

    it 'handles all of the above at the same time!' do
      expect(described_class['formica (Forelophilus) FUSCA Var. flavus st. alba']).to eq 'Formica fusca flavus alba'
    end
  end
end
