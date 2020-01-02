require 'rails_helper'

describe Exporters::Antweb::ExportHistoryItems do
  include TestLinksHelpers

  describe '#call' do
    let(:header) { "<p><b>Taxonomic history</b></p>" }

    context 'when taxon has no history items' do
      let(:taxon) { build_stubbed :family }

      specify { expect(described_class[taxon]).to eq nil }
    end

    context 'when taxon has history items' do
      let(:taxon) { create :family }

      before do
        create :taxon_history_item, taxon: taxon, taxt: "Taxon: {tax #{taxon.id}}"
      end

      specify do
        item = "<div>Taxon: #{antweb_taxon_link(taxon)}.</div>"
        expect(described_class[taxon]).to eq(header + '<div>' + item + '</div>')
      end

      specify { expect(described_class[taxon]).to be_html_safe }
    end

    context 'when taxon has virtual history items' do
      let(:taxon) { create :species }
      let!(:subspecies) { create :subspecies, species: taxon }

      specify do
        virtual_item = "<div>Current subspecies: nominal plus #{antweb_taxon_link(subspecies)}.</div>"
        expect(described_class[taxon]).to eq(header + '<div>' + virtual_item + '</div>')
      end

      specify { expect(described_class[taxon]).to be_html_safe }

      context 'when virtual history item should be visible to editors only' do
        before do
          taxon.history_items.create!(taxt: 'Current subspecies')
        end

        it 'does not include the item' do
          item = "<div>Current subspecies.</div>"
          expect(described_class[taxon]).to eq(header + '<div>' + item + '</div>')
        end
      end
    end

    context 'when taxon has history items and virtual history items' do
      let(:taxon) { create :species }
      let!(:subspecies) { create :subspecies, species: taxon }

      before do
        create :taxon_history_item, taxon: taxon, taxt: "Taxon: {tax #{taxon.id}}"
      end

      specify do
        item = "<div>Taxon: #{antweb_taxon_link(taxon)}.</div>"
        virtual_item = "<div>Current subspecies: nominal plus #{antweb_taxon_link(subspecies)}.</div>"
        expect(described_class[taxon]).to eq(header + '<div>' + item + virtual_item + '</div>')
      end

      specify { expect(described_class[taxon]).to be_html_safe }
    end
  end
end
