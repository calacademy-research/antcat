# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::TaxaQuery do
  context "when there are results" do
    let!(:taxon) { create :family, name_string: "Formicidae" }

    specify { expect(described_class["Formi"]).to eq [taxon] }
  end

  context 'when a taxon ID is given' do
    let!(:taxon) { create :any_taxon }

    specify { expect(described_class[taxon.id.to_s]).to eq [taxon] }
  end
end
