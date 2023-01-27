# frozen_string_literal: true

require "rails_helper"

describe PickerComponent do
  describe '#autocomplete_url' do
    context 'with taxon' do
      specify do
        expect(described_class.new(:taxon, nil, name: 'x').autocomplete_url).to eq "/catalog/autocomplete.html?pickable_type=taxon&per_page=7"
      end
    end

    context 'with taxon and ranks' do
      specify do
        expect(described_class.new(:taxon, nil, name: 'x', ranks: Rank::RANKS_BY_GROUP['Species']).autocomplete_url).
          to eq "/catalog/autocomplete.html?pickable_type=taxon&per_page=7&rank%5B%5D=Species&rank%5B%5D=Subspecies&rank%5B%5D=Infrasubspecies"
      end
    end

    context 'with protonym' do
      specify do
        expect(described_class.new(:protonym, nil, name: 'x').autocomplete_url).to eq "/catalog/autocomplete.html?pickable_type=protonym&per_page=7"
      end
    end

    context 'with reference' do
      specify do
        expect(described_class.new(:reference, nil, name: 'x').autocomplete_url).to eq "/references/autocomplete.html?"
      end
    end
  end
end
