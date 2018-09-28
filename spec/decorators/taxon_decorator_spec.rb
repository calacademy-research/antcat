require 'spec_helper'

describe TaxonDecorator do
  let(:taxon) { create :family }
  let(:decorated) { taxon.decorate }

  describe "#link_to_taxon" do
    specify do
      expect(decorated.link_to_taxon).to eq <<~HTML.squish
        <a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>
      HTML
    end
  end

  describe "#id_and_name_and_author_citation" do
    specify do
      expect(decorated.id_and_name_and_author_citation).to eq <<~HTML.squish
        <span><small class="gray">##{taxon.id}</small>
        <a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>
        <small class="gray">#{taxon.author_citation}</small></span>
      HTML
    end
  end
end
