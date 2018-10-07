require "spec_helper"

describe TaxonDecorator::LinkEachEpithet do
  describe "#call" do
    context 'when taxon is above species-rank' do
      let(:taxon) { create :subfamily }

      it 'just links the genus' do
        expect(described_class[taxon]).to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>)
      end
    end

    context 'when taxon is a species`' do
      let(:taxon) { create :species }

      it 'links the genus and species' do
        expect(described_class[taxon]).to eq(
          %(<a href="/catalog/#{taxon.genus.id}"><i>#{taxon.genus.name_cache}</i></a> ) +
          %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name.species_epithet}</i></a>)
        )
      end
    end

    context 'when taxon is a subspecies`' do
      let(:taxon) { create :subspecies }

      context "when taxon has 2 epithets (standard modern subspecies name)" do
        it 'links the genus, species and subspecies' do
          expect(described_class[taxon]).to eq(
            %(<a href="/catalog/#{taxon.genus.id}"><i>#{taxon.genus.name_cache}</i></a> ) +
            %(<a href="/catalog/#{taxon.species.id}"><i>#{taxon.species.name.species_epithet}</i></a> ) +
            %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name.subspecies_epithets}</i></a>)
          )
        end
      end

      context "when taxon has more than 3 epithets" do
        let!(:genus) { create_genus 'Formica' }
        let!(:species) { create_species 'rufa', genus: genus }
        let!(:subspecies) do
          major_name = SubspeciesName.create! name: 'Formica rufa pratensis major'
          create :subspecies, name: major_name, species: species, genus: genus
        end

        specify do
          expect(described_class[subspecies]).to eq(
            %(<a href="/catalog/#{genus.id}"><i>Formica</i></a> ) +
            %(<a href="/catalog/#{species.id}"><i>rufa</i></a> ) +
            %(<a href="/catalog/#{subspecies.id}"><i>pratensis major</i></a>)
          )
        end
      end
    end
  end
end
