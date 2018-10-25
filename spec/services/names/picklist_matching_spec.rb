# TODO update after extracting from `Name`.

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
        label: '<i>Atta</i>', value: name.name
      ]
    end

    it "can find one fuzzy match" do
      name = create :genus_name, name: 'Gesomyrmex'

      expect(described_class['gyx']).to eq [
        id: name.id, name: name.name,
        label: '<i>Gesomyrmex</i>', value: name.name
      ]
    end

    it "returns the taxon_id, if there is one" do
      bothroponera = create :genus_name, name: 'Bothroponera'
      brachyponera = create_genus 'Brachyponera'

      expect(described_class['bera']).to eq [
        {
          id: bothroponera.id,
          name: bothroponera.name,
          label: '<i>Bothroponera</i>',
          value: bothroponera.name
        },
        {
          id: brachyponera.name.id,
          name: brachyponera.name.name,
          label: '<i>Brachyponera</i>',
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
          label: '<i>Atta</i>',
          value: atta.name
        },
        {
          id: acanthognathus.id,
          name: 'Acanthognathus laevigatus',
          label: '<i>Acanthognathus laevigatus</i>',
          value: acanthognathus.name
        },
        {
          id: acropyga.id,
          name: 'Acropyga dubitata',
          label: '<i>Acropyga dubitata</i>',
          value: acropyga.name
        }
      ]
    end

    it "only returns names attached to species, if that option is sent" do
      create_genus 'Atta'
      create_species 'Atta major'

      results = described_class['atta', species_only: true]
      expect(results.size).to eq 1
      expect(results.first[:name]).to eq 'Atta major'
    end

    it "only returns names attached to genera, if that option is sent" do
      create_genus 'Atta'
      create_species 'Atta major'

      results = described_class['atta', genera_only: true]
      expect(results.size).to eq 1
      expect(results.first[:name]).to eq 'Atta'
    end

    it "only returns names attached to subfamilies or tribes, if that option is sent" do
      subfamily = create :subfamily, name: create(:subfamily_name, name: 'Attinae')
      tribe = create :tribe, name: create(:tribe_name, name: 'Attini')
      create_genus 'Atta', tribe: tribe, subfamily: subfamily
      create_species 'Atta major'

      results = described_class['att', subfamilies_or_tribes_only: true]
      expect(results.size).to eq 2
      expect(results.map { |e| e[:name] }).to match_array ['Attinae', 'Attini']
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
