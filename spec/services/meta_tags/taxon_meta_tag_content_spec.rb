# frozen_string_literal: true

require 'rails_helper'

describe MetaTags::TaxonMetaTagContent do
  describe "#call" do
    context 'when taxon is not excluded from Formicidae' do
      let!(:taxon) { create :subfamily, name_string: 'Peligrosnae' }

      specify do
        expect(described_class[taxon]).
          to eq "Family: Formicidae. Subfamily: Peligrosnae #{taxon.author_citation}. Status: valid."
      end
    end

    context 'when taxon is excluded from Formicidae' do
      let!(:taxon) { create :subfamily, :excluded_from_formicidae, name_string: 'Peligrosnae' }

      specify do
        expect(described_class[taxon]).
          to eq "Excluded from Formicidae. Subfamily: Peligrosnae #{taxon.author_citation}. Status: excluded from Formicidae."
      end
    end
  end
end
