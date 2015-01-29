# coding: UTF-8
require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => subfamily
    expect(subfamily.tribes.map(&:name).map(&:to_s)).to match_array(['Attini', 'Dacetini'])
    expect(subfamily.tribes).to eq(subfamily.children)
  end

  it "should have collective group names" do
    subfamily = create_subfamily
    collective_group_name = create_genus status: 'collective group name', subfamily: subfamily
    create_genus subfamily: subfamily
    expect(subfamily.reload.collective_group_names).to eq([collective_group_name])
  end

  it "should have genera" do
    myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    dacetini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), subfamily: myrmicinae
    create_genus 'Atta', subfamily: myrmicinae, tribe: create_tribe('Attini', subfamily: myrmicinae)
    create_genus 'Acanthognathus', subfamily: myrmicinae, tribe: dacetini
    expect(myrmicinae.genera.map(&:name).map(&:to_s)).to match_array(['Atta', 'Acanthognathus'])
  end

  it "should have species" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, :subfamily => subfamily
    species = FactoryGirl.create :species, :genus => genus
    expect(subfamily.species.size).to eq(1)
  end

  it "should have subspecies" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, subfamily: subfamily
    species = FactoryGirl.create :species, genus: genus
    subspecies = FactoryGirl.create :subspecies, genus: genus, species: species
    expect(subfamily.subspecies.size).to eq(1)
  end

  describe "Name" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_s).to eq('Dolichoderinae')
    end
  end

  describe "Label" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_html).to eq('Dolichoderinae')
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = FactoryGirl.create :subfamily
      expect(subfamily.statistics).to eq({})
    end

    it "should handle 1 valid genus" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1}}})
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :genus, :subfamily => subfamily, :status => 'synonym'}
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1, 'synonym' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :species, :genus => genus, :subfamily => subfamily}
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1}, species: {'valid' => 2}, subspecies: {'valid' => 1}}})
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({ß
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        :fossil => {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should count tribes" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      expect(subfamily.statistics).to eq({
        extant: {tribes: {'valid' => 1}}
      })
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
        expect(subfamily.name.to_s).to eq('Aneuretinae')
        expect(subfamily).not_to be_invalid
        expect(subfamily).to be_fossil
        expect(subfamily.history_items.map(&:taxt)).to eq(['Aneuretinae as subfamily', 'Aneuretini as tribe'])

        expect(subfamily.type_name.to_s).to eq('Atta')
        expect(subfamily.type_name.rank).to eq('genus')

        protonym = subfamily.protonym
        expect(protonym.name.to_s).to eq('Aneuretini')

        authorship = protonym.authorship
        expect(authorship.pages).to eq('6')

        expect(authorship.reference).to eq(reference)

        expect(Update.count).to eq(1)
        update = Update.find_by_record_id subfamily.id
        expect(update.name).to eq('Aneuretinae')
        expect(update.class_name).to eq('Subfamily')
        expect(update.field_name).to eq('create')
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
        expect(subfamily.fossil).to be_falsey
        expect(subfamily.status).to eq('synonym')

        expect(subfamily.type_name.name).to eq('Eciton')
        expect(subfamily.type_fossil).to be_truthy
        expect(subfamily.type_taxt).to eq('Doggedly')

        protonym = subfamily.protonym
        expect(protonym.name.name).to eq('Aneurestini')
        expect(protonym.sic).to be_truthy
        expect(protonym.fossil).to be_truthy
        expect(protonym.authorship.reference.principal_author_last_name).to eq('Fisher')
        expect(protonym.locality).to eq('Canada')

        expect(subfamily.size).to eq(2)
        expect(subfamily.history_items.first.taxt).to eq('Aneuretinae as a big subfamily')
        expect(subfamily.history_items.second.taxt).to eq('Aneuretini as big tribe')
      end
    end

  end
end
