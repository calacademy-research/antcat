require 'spec_helper'

describe SpeciesGroupTaxon do
  it "has its subfamily set from its genus" do
    genus = create :genus
    expect(genus.subfamily).not_to be_nil

    taxon = create :species, genus: genus, subfamily: nil
    expect(taxon.subfamily).to eq genus.subfamily
  end
end
