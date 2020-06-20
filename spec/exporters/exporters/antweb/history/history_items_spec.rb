# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::HistoryItems do
  include TestLinksHelpers

  describe '#call' do
    let(:header) { "<p><b>Taxonomic history</b></p>" }

    context 'when taxon has no history items' do
      let(:taxon) { build_stubbed :any_taxon }

      specify { expect(described_class[taxon]).to eq nil }
    end

    context 'when taxon has history items' do
      let(:taxon) { create :any_taxon }

      before do
        create :taxon_history_item, taxon: taxon, taxt: "Taxon: {tax #{taxon.id}}"
      end

      specify do
        item = "<div>Taxon: #{antweb_taxon_link(taxon)}.</div>"
        expect(described_class[taxon]).to eq(header + '<div>' + item + '</div>')
      end

      specify { expect(described_class[taxon].html_safe?).to eq true }
    end

    context 'when taxon has history items and virtual history items' do
      let(:taxon) { create :species }
      let!(:subspecies) { create :subspecies, name_string: 'Lasius niger aa', species: taxon }
      let(:subspecies_label) { '<i>L. n. aa</i>' }

      before do
        create :taxon_history_item, taxon: taxon, taxt: "Taxon: {tax #{taxon.id}}"
      end

      specify do
        item = "<div>Taxon: #{antweb_taxon_link(taxon)}.</div>"
        virtual_item = "<div>Current subspecies: nominal plus #{antweb_taxon_link(subspecies, subspecies_label)}.</div>"

        expect(described_class[taxon]).to eq(header + '<div>' + item + virtual_item + '</div>')
      end

      specify { expect(described_class[taxon].html_safe?).to eq true }
    end
  end
end
