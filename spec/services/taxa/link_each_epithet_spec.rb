require 'rails_helper'

describe Taxa::LinkEachEpithet do
  include TestLinksHelpers

  describe "#call" do
    context 'when taxon is above species-rank' do
      let(:taxon) { create :subfamily }

      it 'just links the genus' do
        expect(described_class[taxon]).to eq taxon_link(taxon)
      end
    end

    context 'when taxon is a species`' do
      let(:taxon) { create :species }

      it 'links the genus and species' do
        expect(described_class[taxon]).to eq(
          taxon_link(taxon.genus, "<i>#{taxon.genus.name_cache}</i>") + ' ' +
          taxon_link(taxon, "<i>#{taxon.name.species_epithet}</i>")
        )
      end
    end

    context 'when taxon is a subspecies`' do
      let(:taxon) { create :subspecies }

      context "when taxon has 2 epithets (standard modern subspecies name)" do
        it 'links the genus, species and subspecies' do
          expect(described_class[taxon]).to eq(
            taxon_link(taxon.genus, "<i>#{taxon.genus.name_cache}</i>") + ' ' +
            taxon_link(taxon.species, "<i>#{taxon.species.name.species_epithet}</i>") + ' ' +
            taxon_link(taxon, "<i>#{taxon.name.subspecies_epithets}</i>")
          )
        end
      end

      # TODO: Revisit once `DatabaseScripts::QuadrinomialsToBeConverted` has been cleared.
      context "when taxon has more than 3 epithets" do
        let!(:genus) { create :genus, name_string: 'Formica' }
        let!(:species) { create :species, name_string: 'NOTUSED rufa', genus: genus }
        let!(:subspecies) do
          create :subspecies, name_string: 'NOTUSED NOTUSED pratensis major', species: species, genus: genus
        end

        specify do
          expect(described_class[subspecies]).to eq(
            taxon_link(genus, '<i>Formica</i>') + ' ' +
            taxon_link(species, '<i>rufa</i>') + ' ' +
            taxon_link(subspecies, '<i>pratensis major</i>')
          )
        end
      end
    end

    context 'when taxon is an infrasubspecies`' do
      let!(:genus) { create :genus, name_string: 'Formica' }
      let!(:species) { create :species, name_string: 'NOTUSED rufa', genus: genus }
      let!(:subspecies) do
        create :subspecies, name_string: 'NOTUSED NOTUSED pratensis', species: species, genus: genus
      end
      let(:infrasubspecies) do
        create :infrasubspecies, name_string: 'NOTUSED NOTUSED pratensis major', subspecies: subspecies, species: species, genus: genus
      end

      specify do
        expect(described_class[infrasubspecies]).to eq(
          taxon_link(genus, '<i>Formica</i>') + ' ' +
          taxon_link(species, '<i>rufa</i>') + ' ' +
          taxon_link(subspecies, '<i>pratensis</i>') + ' ' +
          taxon_link(infrasubspecies, '<i>major</i>')
        )
      end
    end
  end
end
