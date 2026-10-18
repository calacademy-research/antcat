# frozen_string_literal: true

require 'rails_helper'

describe Detax do
  include TestLinksHelpers

  describe "#call" do
    specify { expect(described_class['string'].html_safe?).to eq true }

    context "when content is nil" do
      specify { expect(described_class[nil]).to eq nil }
    end

    context 'when content contains catalog tags' do
      let(:taxon) { create :family }

      it "renders them" do
        results = described_class["#{Taxt.tax(taxon.id)} pizza"]
        expect(results).to eq "#{taxon_link(taxon)} pizza"
      end
    end

    context 'when a catalog tag is inside an attribute' do
      let(:taxon) { create :family }

      it "drops that attribute instead of expanding the tag into it" do
        results = described_class[%(<span tooltip2="#{Taxt.tax(taxon.id)}">x</span>)]
        expect(results).to eq "<span>x</span>"
        expect(results).not_to include "<a"
      end

      it "escapes markup in kept tooltips" do
        results = described_class[%(<span tooltip2="a <img src=x onerror=1>">x</span> #{Taxt.tax(taxon.id)})]

        expect(Nokogiri::HTML5.fragment(results).css('img, [onerror]')).to be_empty
        expect(results).to include taxon_link(taxon)
      end

      it "keeps a tooltip without catalog tags" do
        expect(described_class[%(<span tooltip2="hint">x</span>)]).to eq %(<span tooltip2="hint">x</span>)
      end
    end

    context 'when content contains non-catalog tags' do
      it "does not render them" do
        expect(described_class['%github1']).to eq '%github1'

        # Sanity check.
        expect(Markdowns::ParseAntCatTags['%github1']).to include 'github.com'
      end
    end
  end
end
