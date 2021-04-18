# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::HistoryItems, :relational_hi do
  include AntwebTestLinksHelpers

  describe '#call' do
    let(:header) { "<p><b>Taxonomic history</b></p>" }

    context 'when taxon has no history items' do
      let(:taxon) { build_stubbed :any_taxon }

      specify { expect(described_class[taxon]).to eq nil }
    end

    context 'when taxon has taxt history items' do
      let(:taxon) { create :any_taxon }

      before do
        create :history_item, :taxt, protonym: taxon.protonym, taxt: "Taxon: {#{Taxt::TAX_TAG} #{taxon.id}}"
      end

      specify do
        antweb_item_1 = "<div>Taxon: #{antweb_taxon_link(taxon)}.</div>"
        expect(described_class[taxon]).to eq(header + '<div>' + antweb_item_1 + '</div>')
      end

      specify { expect(described_class[taxon].html_safe?).to eq true }
    end

    context 'when taxon has taxt and relational history items' do
      let(:taxon) { create :any_taxon }
      let(:protonym) { taxon.protonym }

      let!(:item_1) { create :history_item, :form_descriptions, :with_2000_reference, protonym: protonym }

      context 'with a single item' do
        specify do
          antweb_item_1 = "<div>#{antweb_reference_link(item_1.reference)}: #{item_1.pages} (#{item_1.text_value}).</div>"

          expect(described_class[taxon]).to eq(header + '<div>' + antweb_item_1 + '</div>')
        end
      end

      context 'with grouped items' do
        let!(:item_2) { create :history_item, :form_descriptions, :with_1758_reference, protonym: protonym }

        specify do
          antweb_item_1 = "#{antweb_reference_link(item_1.reference)}: #{item_1.pages} (#{item_1.text_value}).</div>"
          antweb_item_2 = "<div>#{antweb_reference_link(item_2.reference)}: #{item_2.pages} (#{item_2.text_value}); "

          expect(described_class[taxon]).to eq(header + '<div>' + antweb_item_2 + antweb_item_1 + '</div>')
        end
      end

      context 'with more than one item' do
        let!(:item_0) { create :history_item, :taxt, taxt: "Taxon: {#{Taxt::TAX_TAG} #{taxon.id}}", protonym: protonym }

        specify do
          antweb_item_0 = "<div>Taxon: #{antweb_taxon_link(item_0.protonym.terminal_taxon)}.</div>"
          antweb_item_1 = "<div>#{antweb_reference_link(item_1.reference)}: #{item_1.pages} (#{item_1.text_value}).</div>"

          expect(described_class[taxon]).to eq(header + '<div>' + antweb_item_1 + antweb_item_0 + '</div>')
        end
      end

      specify { expect(described_class[taxon].html_safe?).to eq true }
    end
  end
end
