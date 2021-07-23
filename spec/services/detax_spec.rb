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

    context 'when content contains non-catalog tags' do
      it "does not render them" do
        expect(described_class['%github1']).to eq '%github1'

        # Sanity check.
        expect(Markdowns::ParseAntcatTags['%github1']).to include 'github.com'
      end
    end
  end
end
