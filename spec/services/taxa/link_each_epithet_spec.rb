# frozen_string_literal: true

require 'rails_helper'

describe Taxa::LinkEachEpithet do
  include TestLinksHelpers

  describe "#call" do
    context 'when taxon is above species-rank' do
      let(:taxon) { create :subfamily }

      it 'links the uninomial name' do
        expect(described_class[taxon]).to eq taxon_link(taxon)
      end
    end

    context 'when taxon is a species' do
      let(:taxon) { create :species }

      it 'links the genus and species' do
        expect(described_class[taxon]).to eq(
          taxon_link_with_label(taxon.genus, "<i>#{taxon.genus.name_cache}</i>") + ' ' +
          taxon_link_with_label(taxon, "<i>#{taxon.name.species_epithet}</i>")
        )
      end
    end

    context 'when taxon is a subspecies' do
      let(:taxon) { create :subspecies }

      it 'links the genus, species and subspecies' do
        expect(described_class[taxon]).to eq(
          taxon_link_with_label(taxon.genus, "<i>#{taxon.genus.name_cache}</i>") + ' ' +
          taxon_link_with_label(taxon.species, "<i>#{taxon.species.name.species_epithet}</i>") + ' ' +
          taxon_link_with_label(taxon, "<i>#{taxon.name.subspecies_epithet}</i>")
        )
      end
    end

    context 'when taxon is an infrasubspecies' do
      let!(:genus) { create :genus, name_string: 'Formica' }
      let!(:species) { create :species, name_string: 'NOTUSED rufa', genus: genus }
      let!(:subspecies) do
        create :subspecies, name_string: 'NOTUSED NOTUSED pratensis', species: species, genus: genus
      end
      let(:infrasubspecies) do
        create :infrasubspecies, name_string: 'NOTUSED NOTUSED pratensis major',
          subspecies: subspecies, species: species, genus: genus
      end

      specify do
        expect(described_class[infrasubspecies]).to eq(
          taxon_link_with_label(genus, '<i>Formica</i>') + ' ' +
          taxon_link_with_label(species, '<i>rufa</i>') + ' ' +
          taxon_link_with_label(subspecies, '<i>pratensis</i>') + ' ' +
          taxon_link_with_label(infrasubspecies, '<i>major</i>')
        )
      end
    end
  end
end
