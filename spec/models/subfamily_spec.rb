# coding: UTF-8
require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => subfamily
    subfamily.tribes.map(&:name).map(&:to_s).should =~ ['Attini', 'Dacetini']
    subfamily.tribes.should == subfamily.children
  end

  it "should have collective group names" do
    subfamily = create_subfamily
    collective_group_name = create_genus status: 'collective group name', subfamily: subfamily
    create_genus subfamily: subfamily
    subfamily.reload.collective_group_names.should == [collective_group_name]
  end

  it "should have genera" do
    myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    dacetini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), subfamily: myrmicinae
    create_genus 'Atta', subfamily: myrmicinae, tribe: create_tribe('Attini', subfamily: myrmicinae)
    create_genus 'Acanthognathus', subfamily: myrmicinae, tribe: dacetini
    myrmicinae.genera.map(&:name).map(&:to_s).should =~ ['Atta', 'Acanthognathus']
  end

  it "should have species" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, :subfamily => subfamily
    species = FactoryGirl.create :species, :genus => genus
    subfamily.should have(1).species
  end

  it "should have subspecies" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, subfamily: subfamily
    species = FactoryGirl.create :species, genus: genus
    subspecies = FactoryGirl.create :subspecies, genus: genus, species: species
    subfamily.should have(1).subspecies
  end

  describe "Name" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      taxon.name.to_s.should == 'Dolichoderinae'
    end
  end

  describe "Label" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      taxon.name.to_html.should == 'Dolichoderinae'
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = FactoryGirl.create :subfamily
      subfamily.statistics.should == {}
    end

    it "should handle 1 valid genus" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}}}
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :genus, :subfamily => subfamily, :status => 'synonym'}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1, 'synonym' => 2}}} 
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :species, :genus => genus, :subfamily => subfamily}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}}
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      subfamily.statistics.should == {extant: {genera: {'valid' => 1}, species: {'valid' => 2}, subspecies: {'valid' => 1}}}
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      subfamily.statistics.should == {
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        :fossil => {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      }
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      subfamily.statistics.should == {
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      }
    end

    it "should count tribes" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      subfamily.statistics.should == {
        extant: {tribes: {'valid' => 1}}
      }
    end

  end

  describe "Importing" do
    describe "When the subfamily doesn't exist" do
      it "should create the subfamily" do
        reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Emery 1913a'
        subfamily = Subfamily.import(
          subfamily_name: 'Aneuretinae',
          fossil: true,
          protonym: {tribe_name: "Aneuretini",
                    authorship: [{author_names: ["Emery"], year: "1913a", pages: "6"}]},
          type_genus: {genus_name: 'Atta'},
          history: ["Aneuretinae as subfamily", "Aneuretini as tribe"]
        )

        subfamily.reload
        subfamily.name.to_s.should == 'Aneuretinae'
        subfamily.should_not be_invalid
        subfamily.should be_fossil
        subfamily.history_items.map(&:taxt).should == ['Aneuretinae as subfamily', 'Aneuretini as tribe']

        subfamily.type_name.to_s.should == 'Atta'
        subfamily.type_name.rank.should == 'genus'

        protonym = subfamily.protonym
        protonym.name.to_s.should == 'Aneuretini'

        authorship = protonym.authorship
        authorship.pages.should == '6'

        authorship.reference.should == reference

        Update.count.should == 1
        update = Update.find_by_record_id subfamily.id
        update.name.should == 'Aneuretinae'
        update.class_name.should == 'Subfamily'
        update.field_name.should == 'create'
      end
    end

    describe "When the subfamily does exist" do
      before do
        @emery_reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Emery 1913a'
        @data = {
          subfamily_name: 'Aneuretinae',
          fossil: true,
          protonym: {tribe_name: "Aneuretini",
                    authorship: [{author_names: ["Emery"], year: "1913a", pages: "6"}]},
          type_genus: {genus_name: 'Atta'},
          history: ["Aneuretinae as subfamily", "Aneuretini as tribe"]
        }
        @subfamily = Subfamily.import @data
      end

      it "should update the subfamily" do
        fisher_reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Fisher')], bolton_key_cache: 'Fisher 2004'
        data = @data.merge({
          subfamily_name: 'Aneuretinae',
          fossil: false,
          status: 'synonym',
          note: [{phrase: 'Headline notes'}],
          protonym: {tribe_name: "Aneurestini",
                    authorship: [{author_names: ['Fisher'], year: '2004', pages: '7'}],
                    fossil: true, sic: true, locality: 'Canada'},
          type_genus: {genus_name: 'Eciton', fossil: true, texts: [{phrase: 'Doggedly'}]},
          history: ["Aneuretinae as a big subfamily", "Aneuretini as big tribe"],
        })

        subfamily = Subfamily.import data
        subfamily.fossil.should be_false
        subfamily.status.should == 'synonym'

        subfamily.type_name.name.should == 'Eciton'
        subfamily.type_fossil.should be_true
        subfamily.type_taxt.should == 'Doggedly'

        protonym = subfamily.protonym
        protonym.name.name.should == 'Aneurestini'
        protonym.sic.should be_true
        protonym.fossil.should be_true
        protonym.authorship.reference.principal_author_last_name.should == 'Fisher'
        protonym.locality.should == 'Canada'

        subfamily.should have(2).history_items
        subfamily.history_items.first.taxt.should == 'Aneuretinae as a big subfamily'
        subfamily.history_items.second.taxt.should == 'Aneuretini as big tribe'
      end
    end

  end
end
