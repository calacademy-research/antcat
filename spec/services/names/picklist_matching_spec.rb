# TODO update after extracting from `Name`.

require 'spec_helper'

describe Names::PicklistMatching do
  describe "#call" do
    it "returns empty values if no match" do
      expect(described_class['ata']).to eq []
    end

    it "can find one prefix match" do
      name = find_or_create_name 'Atta'
      name.update name_html: '<i>Atta</i>'

      expect(described_class['att']).to eq [
        id: name.id, name: name.name,
        label: '<b><i>Atta</i></b>', value: name.name
      ]
    end

    it "can find one fuzzy match" do
      name = find_or_create_name 'Gesomyrmex'
      name.update name_html: '<i>Gesomyrmex</i>'

      expect(described_class['gyx']).to eq [
        id: name.id, name: name.name,
        label: '<b><i>Gesomyrmex</i></b>', value: name.name
      ]
    end

    it "returns the taxon_id, if there is one" do
      bothroponera = find_or_create_name 'Bothroponera'
      bothroponera.update name_html: '<i>Bothroponera</i>'
      brachyponera = create_genus 'Brachyponera'

      expect(described_class['bera']).to eq [
        {
          id: bothroponera.id,
          name: bothroponera.name,
          label: '<b><i>Bothroponera</i></b>',
          value: bothroponera.name
        },
        {
          id: brachyponera.name.id,
          name: brachyponera.name.name,
          label: '<b><i>Brachyponera</i></b>',
          taxon_id: brachyponera.id,
          value: brachyponera.name.name
        },
      ]
    end

    it "puts prefix matches at the beginning" do
      acropyga = find_or_create_name 'Acropyga dubitata'
      acropyga.update name_html: '<i>Acropyga dubitata</i>'

      atta = find_or_create_name 'Atta'
      atta.update_attribute :name_html, "<i>Atta</i>"

      acanthognathus = find_or_create_name 'Acanthognathus laevigatus'
      acanthognathus.update name_html: '<i>Acanthognathus laevigatus</i>'

      expect(described_class['atta']).to eq [
        {
          id: atta.id,
          name: 'Atta',
          label: '<b><i>Atta</i></b>',
          value: atta.name
        },
        {
          id: acanthognathus.id,
          name: 'Acanthognathus laevigatus',
          label: '<b><i>Acanthognathus laevigatus</i></b>',
          value: acanthognathus.name },
        {
          id: acropyga.id,
          name: 'Acropyga dubitata',
          label: '<b><i>Acropyga dubitata</i></b>',
          value: acropyga.name
        }
      ]
    end

    it "requires the first letter to match either the name or the epithet" do
      find_or_create_name 'Acropyga dubitata'
      find_or_create_name 'Acropyga indubitata'

      results = described_class['dubitata']
      expect(results.size).to eq 1
      expect(results.first[:name]).to eq 'Acropyga dubitata'
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
      subfamily = create_subfamily 'Attinae'
      tribe = create_tribe 'Attini'
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
