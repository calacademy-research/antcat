# coding: UTF-8
require 'spec_helper'

describe Name do

  it "should have a name" do
    expect(Name.new(name:'Name').name).to eq('Name')
  end

  it "should format the fossil symbol" do
    expect(SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(true)).to eq('<i>&dagger;</i><i>major</i>')
    expect(SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(false)).to eq('<i>major</i>')
    expect(GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(true)).to eq('<i>&dagger;</i><i>Atta</i>')
    expect(GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(false)).to eq('<i>Atta</i>')
    expect(SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(true)).to eq('&dagger;Attanae')
    expect(SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(false)).to eq('Attanae')

    expect(SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(false)).to eq('<i>Atta major</i>')
    expect(SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(true)).to eq('<i>&dagger;</i><i>Atta major</i>')
  end

  describe "Updating taxon cache" do
    before do
      @atta = create_name 'Atta'
      @atta.update_attribute :name_html, '<i>Atta</i>'
    end

    it "should set the name_cache and name_html_cache in the taxon when assigned" do
      taxon = create_genus 'Eciton'
      expect(taxon.name_cache).to eq('Eciton')
      expect(taxon.name_html_cache).to eq('<i>Eciton</i>')

      taxon.name = @atta
      taxon.save!
      expect(taxon.name_cache).to eq('Atta')
      expect(taxon.name_html_cache).to eq('<i>Atta</i>')
    end

    it "should change the cache when the contents of the name change" do
      taxon = create_genus name: @atta
      expect(taxon.name_cache).to eq('Atta')
      expect(taxon.name_html_cache).to eq('<i>Atta</i>')
      @atta.update_attributes name: 'Betta', name_html: '<i>Betta</i>'
      taxon.reload
      expect(taxon.name_cache).to eq('Betta')
      expect(taxon.name_html_cache).to eq('<i>Betta</i>')
    end

    it "should change the cache when a different name is assigned" do
      betta = create_name 'Betta'
      betta.update_attribute :name_html, '<i>Betta</i>'

      taxon = create_genus name: @atta
      taxon.update_attribute :name, betta
      expect(taxon.name_cache).to eq('Betta')
      expect(taxon.name_html_cache).to eq('<i>Betta</i>')
    end

  end

  describe "Parse rank" do
    it "should recognize a subfamily name" do
      expect(Name.parse_rank('Dorylinae')).to eq(SubfamilyName)
    end
    it "should recognize a genus name" do
      expect(Name.parse_rank('Atta')).to eq(GenusName)
    end
    it "should recognize a tribe name" do
      expect(Name.parse_rank('Attini')).to eq(TribeName)
    end
    it "should recognize a species name" do
      expect(Name.parse_rank('Atta major')).to eq(SpeciesName)
    end
    it "should recognize a subspecies name" do
      expect(Name.parse_rank('Atta major minor')).to eq(SubspeciesName)
    end
  end

  describe "Parsing" do
    it "should parse a subfamily name" do
      name = Name.parse('Dorylinae')
      expect(name).to be_kind_of SubfamilyName
      expect(name.name).to eq('Dorylinae')
      expect(name.name_html).to eq('Dorylinae')
      expect(name.epithet).to eq('Dorylinae')
      expect(name.epithet_html).to eq('Dorylinae')
      expect(name.protonym_html).to eq('Dorylinae')
    end
    it "should parse a genus name" do
      name = Name.parse('Atta')
      expect(name).to be_kind_of GenusName
      expect(name.name).to eq('Atta')
      expect(name.name_html).to eq('<i>Atta</i>')
      expect(name.epithet).to eq('Atta')
      expect(name.epithet_html).to eq('<i>Atta</i>')
      expect(name.protonym_html).to eq('<i>Atta</i>')
    end
    it "should parse a species name" do
      name = Name.parse('Atta major')
      expect(name).to be_kind_of SpeciesName
      expect(name.name).to eq('Atta major')
      expect(name.name_html).to eq('<i>Atta major</i>')
      expect(name.epithet).to eq('major')
      expect(name.epithet_html).to eq('<i>major</i>')
      expect(name.protonym_html).to eq('<i>Atta major</i>')
    end
    describe "Parsing subspecies names" do
      it "should handle one with two epithets, no type" do
        name = Name.parse('Atta major minor')
        expect(name).to be_kind_of SubspeciesName
        expect(name.name).to eq('Atta major minor')
        expect(name.name_html).to eq('<i>Atta major minor</i>')
        expect(name.epithet).to eq('minor')
        expect(name.epithet_html).to eq('<i>minor</i>')
        expect(name.epithets).to eq('major minor')
        expect(name.protonym_html).to eq('<i>Atta major minor</i>')
      end
      it "should handle one with two epithets, including a type" do
        name = Name.parse('Atta major var. minor')
        expect(name).to be_kind_of SubspeciesName
        expect(name.name).to eq('Atta major var. minor')
        expect(name.name_html).to eq('<i>Atta major var. minor</i>')
        expect(name.epithet).to eq('minor')
        expect(name.epithet_html).to eq('<i>minor</i>')
        expect(name.epithets).to eq('major var. minor')
        expect(name.protonym_html).to eq('<i>Atta major var. minor</i>')
      end
    end

  end

  describe "Name picker list" do

    it "should return empty values if no match" do
      expect(Name.picklist_matching('ata')).to eq([])
    end

    it "should find one prefix match" do
      name = create_name 'Atta'
      name.update_attributes name_html:  '<i>Atta</i>'
      expect(Name.picklist_matching('att')).to eq([id: name.id, name: name.name, label: '<b><i>Atta</i></b>', value: name.name])
    end

    it "should find one fuzzy match" do
      name = create_name 'Gesomyrmex'
      name.update_attributes name_html:  '<i>Gesomyrmex</i>'
      expect(Name.picklist_matching('gyx')).to eq([id: name.id, name: name.name, label: '<b><i>Gesomyrmex</i></b>', value: name.name])
    end

    it "should return the taxon_id, if there is one" do
      bothroponera = create_name 'Bothroponera'
      bothroponera.update_attributes name_html: '<i>Bothroponera</i>'
      brachyponera = create_genus 'Brachyponera'
      expect(Name.picklist_matching('bera')).to eq([
        {id: bothroponera.id,      name: bothroponera.name,      label: '<b><i>Bothroponera</i></b>', value: bothroponera.name},
        {id: brachyponera.name.id, name: brachyponera.name.name, label: '<b><i>Brachyponera</i></b>', taxon_id: brachyponera.id, value: brachyponera.name.name},
      ])
    end

    it "put prefix matches at beginning" do
      acropyga = create_name 'Acropyga dubitata'
      acropyga.update_attributes name_html: '<i>Acropyga dubitata</i>'

      atta = create_name 'Atta'
      atta.update_attribute :name_html, "<i>Atta</i>"

      acanthognathus = create_name 'Acanthognathus laevigatus'
      acanthognathus.update_attributes name_html: '<i>Acanthognathus laevigatus</i>'

      expect(Name.picklist_matching('atta')).to eq([
        {id: atta.id, name: 'Atta', label: '<b><i>Atta</i></b>', value: atta.name},
        {id: acanthognathus.id, name: 'Acanthognathus laevigatus', label: '<b><i>Acanthognathus laevigatus</i></b>', value: acanthognathus.name},
        {id: acropyga.id, name: 'Acropyga dubitata', label: '<b><i>Acropyga dubitata</i></b>', value: acropyga.name},
      ])
    end

    it "should require the first letter to match either the name or the epithet" do
      dubitata = create_name 'Acropyga dubitata'
      indubitata = create_name 'Acropyga indubitata'

      results = Name.picklist_matching('dubitata')
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('Acropyga dubitata')
    end

    it "should only return names attached to taxa, if that option is sent" do
      atta = create_genus 'Atta'
      atta_nudum = create_name 'Attanuda'
      results = Name.picklist_matching('atta', taxa_only: true)
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('Atta')
    end

    it "should only return names attached to species, if that option is sent" do
      atta = create_genus 'Atta'
      atta_minor = create_species 'Atta major'
      results = Name.picklist_matching('atta', species_only: true)
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('Atta major')
    end

    it "should only return names attached to genera, if that option is sent" do
      atta = create_genus 'Atta'
      atta_minor = create_species 'Atta major'
      results = Name.picklist_matching('atta', genera_only: true)
      expect(results.size).to eq(1)
      expect(results.first[:name]).to eq('Atta')
    end

    it "should only return names attached to subfamilies or tribes, if that option is sent" do
      subfamily = create_subfamily 'Attinae'
      tribe = create_tribe 'Attini'
      atta = create_genus 'Atta', tribe: tribe, subfamily: subfamily
      atta_minor = create_species 'Atta major'
      results = Name.picklist_matching('att', subfamilies_or_tribes_only: true)
      expect(results.size).to eq(2)
      expect(results.map {|e| e[:name]}).to match_array(['Attinae', 'Attini'])
    end

    it "should prioritize names already associated with taxa" do
      atta_name = FactoryGirl.create :name, name: 'Atta'
      taxon = create_genus 'Atta'
      results = Name.picklist_matching('Atta')
      expect(taxon.name_id).not_to eq(atta_name.id)
      expect(results.first[:id]).to eq(taxon.name_id)
    end

  end

  describe "Duplicates" do
    it "should return the records with same name but different ID" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      not_atta_name = FactoryGirl.create :name, name: 'Notatta'
      expect(Name.duplicates).to match_array([first_atta_name, second_atta_name])
    end
  end

  describe "Duplicates and references" do
    it "should return the references to the duplicate names" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      first_atta = create_genus name: first_atta_name
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      second_atta = create_genus name: second_atta_name

      results = Name.duplicates_with_references

      expect(results).to eq({
        'Atta' => {
          first_atta_name.id => [
            {table: 'taxa', field: :name_id, id: first_atta.id},
          ],
          second_atta_name.id => [
            {table: 'taxa', field: :name_id, id: second_atta.id},
          ],
        }
      })
    end
  end

  describe "Deleting duplicate names" do
    it "should delete duplicate names" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      genus = create_genus name: first_atta_name
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      not_atta_name = FactoryGirl.create :name, name: 'Notatta'
      Name.destroy_duplicates
      expect(Name.find_by_id(first_atta_name)).not_to be_nil
      expect(Name.find_by_id(second_atta_name)).to be_nil
      expect(Name.find_by_id(not_atta_name)).not_to be_nil
    end
  end

  describe "References" do
    it "should return references in fields" do
      atta = create_genus 'Atta'
      protonym = FactoryGirl.create :protonym, name: atta.name
      atta.update_attribute :protonym, protonym
      atta.update_attribute :type_name, atta.name
      expect(atta.name.references).to match_array([
        {table: 'taxa', field: :name_id, id: atta.id},
        {table: 'taxa', field: :type_name_id, id: atta.id},
        {table: 'protonyms', field: :name_id, id: protonym.id},
      ])
    end
    it "should return references in taxt" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.update_attribute :type_taxt, "{nam #{atta.name.id}}"
      expect(atta.name.references).to match_array([
        {table: 'taxa', field: :name_id, id: atta.id},
        {table: 'taxa', field: :type_taxt, id: eciton.id},
      ])
    end
  end

  describe "references_in_taxt" do
    it "return instances that reference this name" do
      name = Name.create! name: 'Atta'
      # create an instance for each type of taxt
      Taxt.taxt_fields.each do |klass, fields|
        for field in fields
          FactoryGirl.create klass, field => "{nam #{name.id}}"
        end
      end
      refs = name.references_in_taxt
      # count the total referencing items
      expect(refs.length).to eq(
        Taxt.taxt_fields.collect{ |klass, fields| fields.length }.inject(&:+)
      )
      # count the total referencing items of each type
      Taxt.taxt_fields.each do |klass, fields|
        for field in fields
          expect(refs.select{ |i| i[:table] == klass.table_name }.length).to eq(
            Taxt.taxt_fields.detect{ |k, f| k == klass }[1].length
          )
        end
      end
    end
  end

  describe "Versioning" do
    it "should record an add" do
      with_versioning do
        name = Name.create! name: 'Atta'
        versions = name.versions
        version = versions.last
        expect(version.event).to eq('create')
      end
    end
    it "should record an update" do
      name = Name.create! name: 'Atta'
      with_versioning do
        name.update_attribute :name, 'Eciton'
        versions = name.versions
        version = versions.last
        expect(version.event).to eq('update')
      end
    end
    it "should record a create" do
      name = Name.new name: 'Atta'
      with_versioning do
        name['name'] = 'Eciton'
        name.save!
        versions = name.versions
        version = versions.last
        expect(version.event).to eq('create')
      end
    end
    it "should record an add followed by an update" do
      with_versioning do
        name = Name.create! name: 'Atta'
        version = name.versions(true).last
        expect(version.event).to eq('create')

        name['name'] = 'Eciton'
        name.save!

        versions = name.versions(true)
        expect(name.versions.count).to eq(2)

        version = versions.first
        expect(version.event).to eq('create')
        version = versions.last
        expect(version.event).to eq('update')
      end
    end
  end

  describe "Finding trinomials that are like quadronimals" do
    it "should return those taxa with names that differ in this way" do
      create_subspecies 'Camponotus maculatus georgei'
      create_subspecies 'Camponotus maculatus arnoldius georgei'
      create_subspecies 'Camponotus maculatus alpaca'
      expect(Name.find_trinomials_like_quadrinomials).to match_array([
        'Camponotus maculatus georgei'
      ])
    end
  end

  describe "Quadrinomial?" do
    it "should just consider quadrinomials quadrinomials - nothing else" do
      name = SubfamilyName.new name: 'Acidinae', name_html: 'Acidinae', epithet: 'Acidinae',
        epithet_html: 'Acidinae', epithets: nil, protonym_html: 'Acidinae'
      expect(name).not_to be_quadrinomial

      name = TribeName.new name: 'Acidini', name_html: 'Acidini', epithet: 'Acidini',
        epithet_html: 'Acidini', epithets: nil, protonym_html: 'Acidini'
      expect(name).not_to be_quadrinomial

      name = GenusName.new name: 'Acus', name_html: '<i>Acus</i>', epithet: 'Acus',
        epithet_html: '<i>Acus</i>', epithets: nil, protonym_html: '<i>Acus</i>'
      expect(name).not_to be_quadrinomial

      name = SubgenusName.new name: 'Acus (Rex)', name_html: '<i>Acus (Rex)</i>', epithet: 'Rex',
        epithet_html: '<i>Rex</i>', epithets: nil, protonym_html: '<i>Acus (Rex)</i>'
      expect(name).not_to be_quadrinomial

      name = SpeciesName.new name: 'Acus major', name_html: '<i>Acus major</i>', epithet: 'major',
        epithet_html: '<i>major</i>', epithets: 'major', protonym_html: '<i>Acus major</i>'
      expect(name).not_to be_quadrinomial

      name = SubspeciesName.new name: 'Acus major minor', name_html: '<i>Acus major minor</i>', epithet: 'major minor',
        epithet_html: '<i>major minor</i>', epithets: 'major minor', protonym_html: '<i>Acus major minor</i>'
      expect(name).not_to be_quadrinomial

      name = SubspeciesName.new name: 'Acus major minor medium', name_html: '<i>Acus major minor medium</i>', epithet: 'medium',
        epithet_html: '<i>medium</i>', epithets: 'major minor medium', protonym_html: '<i>Acus major minor medium</i>'
      expect(name).to be_quadrinomial

    end
  end

  describe "Indexing" do
    it "should work as expected" do
      name = SubspeciesName.new name: 'Acus major minor medium', name_html: '<i>Acus major minor medium</i>', epithet: 'medium',
        epithet_html: '<i>medium</i>', epithets: 'major minor medium', protonym_html: '<i>Acus major minor medium</i>'
      expect(name.at(0)).to eq('Acus')
      expect(name.at(1)).to eq('major')
      expect(name.at(2)).to eq('minor')
      expect(name.at(3)).to eq('medium')

      name = GenusName.new name: 'Acus', name_html: '<i>Acus</i>', epithet: 'Acus',
        epithet_html: '<i>Acus</i>', epithets: nil, protonym_html: '<i>Acus</i>'
      expect(name.at(0)).to eq('Acus')
      expect(name.at(1)).to be_nil
      expect(name.at(2)).to be_nil
      expect(name.at(3)).to be_nil
    end
  end

  describe "find_by_name" do
    it "should prioritize names already associated with taxa" do
      atta_name = FactoryGirl.create :name, name: 'Atta'
      taxon = create_genus 'Atta'
      expect(taxon.name).not_to eq(atta_name)
      expect(Name.find_by_name('Atta')).to eq(taxon.name)
    end
  end

end
