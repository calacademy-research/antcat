require "spec_helper"

describe TaxonDecorator::HeadlineType do
  let(:species_name) { create :species_name, name: 'Atta major' }

  describe "#call" do
    it "shows the type taxon" do
      taxon = create :genus, type_name: species_name
      expect(described_class[taxon]).
        to eq %(<span>Type-species: <span><i>Atta major</i></span>.</span>)
    end

    it "shows the type taxon with extra Taxt" do
      taxon = create :genus, type_name: species_name, type_taxt: ', by monotypy'
      expect(described_class[taxon]).
        to eq %(<span>Type-species: <span><i>Atta major</i></span>, by monotypy.</span>)
    end
  end

  describe "#format_type_name" do
    let!(:type) { create_species 'Atta major' }
    let!(:taxon) { create :genus, type_name: species_name }

    it "shows the type taxon as a link, if the taxon for the name exists" do
      expect(described_class.new(taxon).send(:format_type_name)).
        to eq %(<a href="/catalog/#{type.id}"><i>Atta major</i></a>)
    end
  end
end
