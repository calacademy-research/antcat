require 'spec_helper'

describe Names::PicklistMatching do
  describe "#call" do
    it "returns empty values if no match" do
      expect(described_class['ata']).to eq []
    end

    it "can find one prefix match" do
      name = create :genus_name, name: 'Atta'

      expect(described_class['att']).to eq [
        id: name.id, name: name.name,
        label: 'Atta', value: name.name
      ]
    end

    it "can find one fuzzy match" do
      name = create :genus_name, name: 'Gesomyrmex'

      expect(described_class['gyx']).to eq [
        id: name.id, name: name.name,
        label: 'Gesomyrmex', value: name.name
      ]
    end

    it "returns the taxon_id, if there is one" do
      bothroponera = create :genus_name, name: 'Bothroponera'
      brachyponera = create_genus 'Brachyponera'

      expect(described_class['bera']).to eq [
        {
          id: bothroponera.id,
          name: bothroponera.name,
          label: 'Bothroponera',
          value: bothroponera.name
        },
        {
          id: brachyponera.name.id,
          name: brachyponera.name.name,
          label: 'Brachyponera',
          taxon_id: brachyponera.id,
          value: brachyponera.name.name
        }
      ]
    end

    it "puts prefix matches at the beginning" do
      acropyga = create :genus_name, name: 'Acropyga dubitata'
      atta = create :genus_name, name: 'Atta'
      acanthognathus = create :genus_name, name: 'Acanthognathus laevigatus'

      expect(described_class['atta']).to eq [
        {
          id: atta.id,
          name: 'Atta',
          label: 'Atta',
          value: atta.name
        },
        {
          id: acanthognathus.id,
          name: 'Acanthognathus laevigatus',
          label: 'Acanthognathus laevigatus',
          value: acanthognathus.name
        },
        {
          id: acropyga.id,
          name: 'Acropyga dubitata',
          label: 'Acropyga dubitata',
          value: acropyga.name
        }
      ]
    end

    it "prioritizes names already associated with taxa" do
      atta_name = create :name, name: 'Atta'
      taxon = create_genus 'Atta'

      results = described_class['atta']
      expect(taxon.name_id).not_to eq atta_name.id
      expect(results.first[:id]).to eq taxon.name_id
    end
  end
end
