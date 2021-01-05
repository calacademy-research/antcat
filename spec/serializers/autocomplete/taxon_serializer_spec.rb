# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::TaxonSerializer do
  describe "#as_json" do
    let!(:taxon) { create :genus, :fossil, name_string: "Atta" }

    specify do
      expect(described_class.new(taxon).as_json).to eq(
        {
          id: taxon.id,
          plaintext_name: taxon.name_cache,
          name_with_fossil: "<i>†</i><i>#{taxon.name_cache}</i>",
          author_citation: taxon.author_citation,
          css_classes: CatalogFormatter.taxon_disco_mode_css(taxon),
          url: "/catalog/#{taxon.id}"
        }
      )
    end

    context 'with `include_protonym`' do
      specify do
        serialized = described_class.new(taxon).as_json(include_protonym: true)
        serialized_protonym = Autocomplete::ProtonymSerializer.new(taxon.protonym).as_json

        expect(serialized[:protonym]).to eq serialized_protonym
      end
    end
  end
end
