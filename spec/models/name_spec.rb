require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  it "should format the fossil symbol" do
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>major</i>'
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(false).should == '<i>major</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>Atta</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(false).should == '<i>Atta</i>'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(true).should == '&dagger;Attanae'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(false).should == 'Attanae'

    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(false).should == '<i>Atta major</i>'
    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(true).should == '<i>&dagger;</i><i>Atta major</i>'
  end

  describe "Updating taxon cache" do
    before do
      @atta = create_name 'Atta'
      @atta.update_attribute :name_html, '<i>Atta</i>'
    end

    it "should set the name_cache and name_html_cache in the taxon when assigned" do
      taxon = create_genus 'Eciton'
      taxon.name_cache.should == 'Eciton'
      taxon.name_html_cache.should == '<i>Eciton</i>'

      taxon.name = @atta
      taxon.save!
      taxon.name_cache.should == 'Atta'
      taxon.name_html_cache.should == '<i>Atta</i>'
    end

    it "should change the cache when the contents of the name change" do
      taxon = create_genus name: @atta
      taxon.name_cache.should == 'Atta'
      taxon.name_html_cache.should == '<i>Atta</i>'
      @atta.update_attributes name: 'Betta', name_html: '<i>Betta</i>'
      taxon.reload
      taxon.name_cache.should == 'Betta'
      taxon.name_html_cache.should == '<i>Betta</i>'
    end

    it "should change the cache when a different name is assigned" do
      betta = create_name 'Betta'
      betta.update_attribute :name_html, '<i>Betta</i>'

      taxon = create_genus name: @atta
      taxon.update_attribute :name, betta
      taxon.name_cache.should == 'Betta'
      taxon.name_html_cache.should == '<i>Betta</i>'
    end

  end

  describe "Parsing" do
    it "should parse a genus name" do
      name = Name.parse('Atta')
      name.should be_kind_of GenusName
      name.name.should == 'Atta'
      name.name_html.should == '<i>Atta</i>'
      name.epithet.should == 'Atta'
      name.epithet_html.should == '<i>Atta</i>'
      name.protonym_html.should == '<i>Atta</i>'
    end
    it "should parse a species name" do
      name = Name.parse('Atta major')
      name.should be_kind_of SpeciesName
      name.name.should == 'Atta major'
      name.name_html.should == '<i>Atta major</i>'
      name.epithet.should == 'major'
      name.epithet_html.should == '<i>major</i>'
      name.protonym_html.should == '<i>major</i>'
    end
    describe "Parsing subspecies names" do
      it "should handle one with two epithets, no type" do
        name = Name.parse('Atta major minor')
        name.should be_kind_of SubspeciesName
        name.name.should == 'Atta major minor'
        name.name_html.should == '<i>Atta major minor</i>'
        name.epithet.should == 'minor'
        name.epithet_html.should == '<i>minor</i>'
        name.epithets.should == 'major minor'
        name.protonym_html.should == '<i>major minor</i>'
      end
      it "should handle one with two epithets, including a type" do
        name = Name.parse('Atta major var. minor')
        name.should be_kind_of SubspeciesName
        name.name.should == 'Atta major var. minor'
        name.name_html.should == '<i>Atta major var. minor</i>'
        name.epithet.should == 'minor'
        name.epithet_html.should == '<i>minor</i>'
        name.epithets.should == 'major var. minor'
        name.protonym_html.should == '<i>major var. minor</i>'
      end
    end

  end

  describe "Name picker list" do

    it "should return empty values if no match" do
      Name.picklist_matching('ata').should == []
    end

    it "should find one prefix match" do
      name = create_name 'Atta'
      name.update_attributes name_html:  '<i>Atta</i>'
      Name.picklist_matching('att').should == [id: name.id, name: name.name, label: '<b><i>Atta</i></b>', value: name.name]
    end

    it "should find one fuzzy match" do
      name = create_name 'Gesomyrmex'
      name.update_attributes name_html:  '<i>Gesomyrmex</i>'
      Name.picklist_matching('gyx').should == [id: name.id, name: name.name, label: '<b><i>Gesomyrmex</i></b>', value: name.name]
    end

    it "should return the taxon_id, if there is one" do
      bothroponera = create_name 'Bothroponera'
      bothroponera.update_attributes name_html: '<i>Bothroponera</i>'
      brachyponera = create_genus 'Brachyponera'
      Name.picklist_matching('bera').should == [
        {id: bothroponera.id,      name: bothroponera.name,      label: '<b><i>Bothroponera</i></b>', value: bothroponera.name},
        {id: brachyponera.name.id, name: brachyponera.name.name, label: '<b><i>Brachyponera</i></b>', taxon_id: brachyponera.id, value: brachyponera.name.name},
      ]
    end

    it "put prefix matches at beginning" do
      acropyga = create_name 'Acropyga dubitata'
      acropyga.update_attributes name_html: '<i>Acropyga dubitata</i>'

      atta = create_name 'Atta'
      atta.update_attribute :name_html, "<i>Atta</i>"

      acanthognathus = create_name 'Acanthognathus laevigatus'
      acanthognathus.update_attributes name_html: '<i>Acanthognathus laevigatus</i>'

      Name.picklist_matching('atta').should == [
        {id: atta.id, name: 'Atta', label: '<b><i>Atta</i></b>', value: atta.name},
        {id: acanthognathus.id, name: 'Acanthognathus laevigatus', label: '<b><i>Acanthognathus laevigatus</i></b>', value: acanthognathus.name},
        {id: acropyga.id, name: 'Acropyga dubitata', label: '<b><i>Acropyga dubitata</i></b>', value: acropyga.name},
      ]
    end

    it "should require the first letter to match either the name or the epithet" do
      dubitata = create_name 'Acropyga dubitata'
      indubitata = create_name 'Acropyga indubitata'

      results = Name.picklist_matching('dubitata')
      results.should have(1).item
      results.first[:name].should == 'Acropyga dubitata'
    end

  end

  describe "Duplicates" do
    it "should return the records with same name but different ID" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      not_atta_name = FactoryGirl.create :name, name: 'Notatta'
      Name.duplicates.should =~ [first_atta_name, second_atta_name]
    end
  end

  describe "Duplicates and references" do
    it "should return the references to the duplicate names" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      first_atta = create_genus name: first_atta_name
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      second_atta = create_genus name: second_atta_name

      results = Name.duplicates_with_references

      results.should == {
        'Atta' => {
          first_atta_name.id => [
            {table: 'taxa', field: 'name_id', id: first_atta.id},
          ],
          second_atta_name.id => [
            {table: 'taxa', field: 'name_id', id: second_atta.id},
          ],
        }
      }
    end
  end

  describe "Deleting duplicate names" do
    it "should delete duplicate names" do
      first_atta_name = FactoryGirl.create :name, name: 'Atta'
      genus = create_genus name: first_atta_name
      second_atta_name = FactoryGirl.create :name, name: 'Atta'
      not_atta_name = FactoryGirl.create :name, name: 'Notatta'
      Name.destroy_duplicates
      Name.find_by_id(first_atta_name).should_not be_nil
      Name.find_by_id(second_atta_name).should be_nil
      Name.find_by_id(not_atta_name).should_not be_nil
    end
  end

  describe "References" do
    it "should return references in fields" do
      atta = create_genus 'Atta'
      protonym = FactoryGirl.create :protonym, name: atta.name
      atta.update_attribute :protonym, protonym
      atta.update_attribute :type_name, atta.name
      atta.name.references.should =~ [
        {table: 'taxa', field: 'name_id', id: atta.id},
        {table: 'taxa', field: 'type_name_id', id: atta.id},
        {table: 'protonyms', field: 'name_id', id: protonym.id},
      ]
    end
    it "should return references in taxt" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.update_attribute :type_taxt, "{nam #{atta.name.id}}"
      atta.name.references.should =~ [
        {table: 'taxa', field: 'name_id', id: atta.id},
        {table: 'taxa', field: 'type_taxt', id: eciton.id},
      ]
    end
  end

end
