require "spec_helper"

describe TaxonDecorator::HeadlineType do
  include TestLinksHelpers

  describe "#call" do
    context "when taxon has a type name" do
      let(:type_species) { create_species 'Atta major' }
      let(:taxon) { create :genus, type_taxon: type_species }

      it "links the type name" do
        expect(described_class[taxon]).to eq %(<span>Type-species: #{taxon_link(type_species)}.</span>)
      end

      context "when taxon has type taxt" do
        let(:taxon) { create :genus, type_taxon: type_species, type_taxt: ', by monotypy' }

        it "includes the type taxt" do
          expect(described_class[taxon]).
            to eq %(<span>Type-species: #{taxon_link(type_species)}, by monotypy.</span>)
        end
      end
    end

    context "when taxon does not have a type name" do
      let(:taxon) { create :genus }

      specify { expect(described_class[taxon]).to eq "" }
    end
  end
end
