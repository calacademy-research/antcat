require "spec_helper"

describe TaxonDecorator::LinkEachEpithet do
  describe "#call" do
    context 'when taxon is above species-rank' do
      let(:taxon) { create(:subfamily) }

      it 'just links the genus' do
        expect(described_class[taxon]).to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>)
      end
    end

    context 'when taxon is a species`' do
      let(:taxon) { create_species }

      it 'links the genus and species' do
        expect(described_class[taxon]).to eq(
          %(<a href="/catalog/#{taxon.genus.id}"><i>#{taxon.genus.name_cache}</i></a> ) +
          %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name.species_epithet}</i></a>)
        )
      end
    end

    context 'when taxon is a subspecies`' do
      let(:taxon) { create_subspecies }

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
        let!(:formica) { create_genus 'Formica' }
        let!(:rufa) { create_species 'rufa', genus: formica }
        let!(:major) do
          major_name = Name.create! name: 'Formica rufa pratensis major',
            epithet_html: '<i>major</i>',
            epithets: 'rufa pratensis major'
          create_subspecies name: major_name, species: rufa, genus: rufa.genus
        end

        specify do
          expect(described_class[major]).to eq(
            %(<a href="/catalog/#{formica.id}"><i>Formica</i></a> ) +
            %(<a href="/catalog/#{rufa.id}"><i>rufa</i></a> ) +
            %(<a href="/catalog/#{major.id}"><i>pratensis major</i></a>)
          )
        end
      end
    end

    context 'when taxon has a non-conforming name`' do
      let(:taxon) { create_subspecies }

      before { taxon.name.update nonconforming_name: true }

      it 'links the genus, and links the rest of the name to the taxon' do
        expect(described_class[taxon]).to eq(
          %(<a href="/catalog/#{taxon.genus.id}"><i>#{taxon.genus.name_cache}</i></a> ) +
          %(<a href="/catalog/#{taxon.id}"><i>major minor</i></a>)
        )
      end
    end
  end
end
