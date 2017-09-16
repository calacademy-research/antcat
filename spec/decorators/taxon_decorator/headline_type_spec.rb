require "spec_helper"

describe TaxonDecorator::HeadlineType do
  let(:species_name) { create :species_name, name: 'Atta major', epithet: 'major' }

  describe "#call" do
    it "shows the type taxon" do
      genus = create_genus 'Atta', type_name: species_name
      expect(described_class[genus])
        .to eq %{<span>Type-species: <span><i>Atta major</i></span>.</span>}
    end

    it "shows the type taxon with extra Taxt" do
      genus = create_genus 'Atta', type_name: species_name, type_taxt: ', by monotypy'
      expect(described_class[genus])
        .to eq %{<span>Type-species: <span><i>Atta major</i></span>, by monotypy.</span>}
    end
  end

  describe "#headline_type_name" do
    let!(:type) { create_species 'Atta major' }
    let!(:genus) { create_genus 'Atta', type_name: create(:species_name, name: 'Atta major') }

    it "shows the type taxon as a link, if the taxon for the name exists" do
      expect(described_class.new(genus).send(:headline_type_name))
        .to eq %Q{<a href="/catalog/#{type.id}"><i>Atta major</i></a>}
    end
  end
end
