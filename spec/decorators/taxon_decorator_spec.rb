require 'spec_helper'

describe TaxonDecorator do
  describe "#link_to_taxon" do
    let(:taxon) { create :family }

    it "creates the link" do
      expect(taxon.decorate.link_to_taxon).
        to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name.name}</a>)
    end
  end
end
