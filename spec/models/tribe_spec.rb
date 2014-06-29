# coding: UTF-8
require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    Tribe.find_by_name('Attini').subfamily.should == subfamily
  end

  it "should have genera, which are its children" do
    attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini')
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Acromyrmex'), :tribe => attini
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :tribe => attini
    attini.genera.map(&:name).map(&:to_s).should =~ ['Atta', 'Acromyrmex']
    attini.children.should == attini.genera
  end

  it "should have as its full name just its name" do
    taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    taxon.name.to_s.should == 'Attini'
  end

  it "should have as its label, just its name" do
    taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    taxon.name.to_html.should == 'Attini'
  end

  describe "Siblings" do

    it "should return itself and its subfamily's other tribes" do
      FactoryGirl.create :tribe
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      another_tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      tribe.siblings.should =~ [tribe, another_tribe]
    end

  end

  describe "Statistics" do
    it "should include the number of genera" do
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, tribe: tribe
      tribe.statistics.should == {:extant => {:genera => {'valid' => 1}}}
    end
  end

  describe "Importing" do
    it "should work" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Emery 1913a'
      tribe = Tribe.import(
        tribe_name: 'Aneuretini',
        fossil: true,
        protonym: {tribe_name: "Aneuretini",
                   authorship: [{author_names: ["Emery"], year: "1913a", pages: "6"}]},
        type_genus: {genus_name: 'Atta'},
        history: ["Aneuretini history"]
      )

      tribe.reload

      tribe.name.to_s.should == 'Aneuretini'
      tribe.should_not be_invalid
      tribe.should be_fossil
      tribe.history_items.map(&:taxt).should == ['Aneuretini history']

      tribe.type_name.to_s.should == 'Atta'
      tribe.type_name.rank.should == 'genus'

      protonym = tribe.protonym
      protonym.name.to_s.should == 'Aneuretini'

      authorship = protonym.authorship
      authorship.pages.should == '6'

      authorship.reference.should == reference

      Update.count.should == 1
    end
  end

  describe "Updating" do
    it "should record a change in parent taxon" do
      dolichoderinae = create_subfamily 'Dolichoderinae'
      fisher_reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Fisher')], bolton_key_cache: 'Fisher 2004'
      data = {
        tribe_name: 'Aneuretinae',
        protonym: {
          tribe_name: "Aneurestini",
          authorship: [{author_names: ['Fisher'], year: '2004', pages: '7'}],
        },
        type_genus: {genus_name: 'Eciton'},
        history: [],
        subfamily: dolichoderinae
      }
      tribe = Tribe.import data

      tribe.subfamily.should == dolichoderinae

      aectinae = create_subfamily 'Aectinae'
      data[:subfamily] = aectinae

      tribe = Tribe.import data

      tribe.subfamily.should == aectinae

      Update.count.should == 2
      update = Update.find_by_field_name('create')
      update.should_not be_nil

      update = Update.find_by_record_id_and_field_name tribe, :subfamily_id
      update.before.should == 'Dolichoderinae'
      update.after.should == 'Aectinae'
    end

  end

  describe "Updating the parent" do
    it "should assign the subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      new_subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      tribe.update_parent new_subfamily
      tribe.subfamily.should == new_subfamily
    end

    it "should assign the subfamily of its descendants" do
      subfamily = FactoryGirl.create :subfamily
      new_subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      subspecies = create_subspecies species: species, genus: genus
      # test the initial subfamilies
      tribe.subfamily.should == subfamily
      tribe.genera.first.subfamily.should == subfamily
      tribe.genera.first.species.first.subfamily.should == subfamily
      tribe.genera.first.subspecies.first.subfamily.should == subfamily
      # test the updated subfamilies
      tribe.update_parent new_subfamily
      tribe.subfamily.should == new_subfamily
      tribe.genera.first.subfamily.should == new_subfamily
      tribe.genera.first.species.first.subfamily.should == new_subfamily
      tribe.genera.first.subspecies.first.subfamily.should == new_subfamily
    end
  end

end
