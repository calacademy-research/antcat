require "spec_helper"

describe Exporters::Antweb::ExportHeadlineType do
  describe "#call" do
    context "when taxon has a type name" do
      let(:type_species) { create :species, name_string: 'Atta major' }
      let(:taxon) { create :genus, type_taxon: type_species }
      let(:taxon_link) { %(<a href="http://www.antcat.org/catalog/#{type_species.id}"><i>Atta major</i></a>) }

      it "links the type name" do
        expect(described_class[taxon]).to eq %(Type-species: #{taxon_link}.)
      end

      context "when taxon has type taxt" do
        let(:taxon) { create :genus, type_taxon: type_species, type_taxt: ', by monotypy' }

        it "includes the type taxt" do
          expect(described_class[taxon]).
            to eq %(Type-species: #{taxon_link}, by monotypy.)
        end
      end
    end

    context "when taxon does not have a type name" do
      let(:taxon) { create :genus }

      specify { expect(described_class[taxon]).to eq "" }
    end
  end
end
