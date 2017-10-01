require 'spec_helper'

describe TaxonDecorator do
  describe "#link_to_taxon" do
    let(:genus) { create_genus 'Atta' }

    it "creates the link" do
      expect(genus.decorate.link_to_taxon).to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
    end
  end
end
