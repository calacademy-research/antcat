# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::TaxaQuery do
  context 'when a taxon ID is given' do
    let!(:taxon) { create :any_taxon }

    specify { expect(described_class[taxon.id.to_s]).to eq [taxon] }
  end

  context "when there are results" do
    let!(:family) { create :family, name_string: "Formicidae" }

    specify { expect(described_class["Formi"]).to eq [family] }

    context "with `rank`" do
      let!(:genus) { create :genus, name_string: "Formica" }

      it 'only returns matches with that `type`' do
        expect(described_class["Formi", rank: Rank::GENUS]).to eq [genus]
        expect(described_class["Formi", rank: Rank::FAMILY]).to eq [family]
      end
    end
  end
end
