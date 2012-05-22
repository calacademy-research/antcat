# coding: UTF-8
require 'spec_helper'

describe Species do

  it "should have a genus" do
    genus = FactoryGirl.create :genus, :name => 'Atta'
    FactoryGirl.create :species, :name => 'championi', :genus => genus
    Species.find_by_name('championi').genus.should == genus
  end

  it "can have a subgenus" do
    subgenus = FactoryGirl.create :subgenus, :name => 'Atta'
    FactoryGirl.create :species, :name => 'championi', :subgenus => subgenus
    Species.find_by_name('championi').subgenus.should == subgenus
  end

  it "should have a subfamily" do
    genus = FactoryGirl.create :genus, :name => 'Atta'
    FactoryGirl.create :species, :name => 'championi', :genus => genus
    Species.find_by_name('championi').subfamily.should == genus.subfamily
  end

  it "doesn't need a genus" do
    FactoryGirl.create :species, :name => 'championi', :genus => nil
    Species.find_by_name('championi').genus.should be_nil
  end

  it "should have subspecies, which are its children" do
    species = FactoryGirl.create :species, :name => 'chilensis'
    FactoryGirl.create :subspecies, :name => 'robusta', :species => species
    FactoryGirl.create :subspecies, :name => 'saltensis', :species => species
    species = Species.find_by_name 'chilensis'
    species.subspecies.map(&:name).should =~ ['robusta', 'saltensis']
    species.children.should == species.subspecies
  end

  describe "Full name" do
    it "should handle it when it has a subfamily" do
      subfamily = FactoryGirl.create :subfamily, :name => 'Dolichoderinae'
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :name => 'Myrmicium'
      species = FactoryGirl.create :species, :genus => genus, :name => 'shattucki'
      species.full_name.should == 'Myrmicium shattucki'
    end
    it "should handle it when it has no subfamily" do
      genus = FactoryGirl.create :genus, :subfamily => nil, :name => 'Myrmicium'
      species = FactoryGirl.create :species, :genus => genus, :name => 'shattucki'
      species.full_name.should == 'Myrmicium shattucki'
    end
  end

  describe "Full label" do
    it "should handle it when it has a subfamily" do
      subfamily = FactoryGirl.create :subfamily, :name => 'Dolichoderinae'
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :name => 'Myrmicium'
      species = FactoryGirl.create :species, :genus => genus, :name => 'shattucki'
      species.full_label.should == '<i>Myrmicium shattucki</i>'
    end
    it "should handle it when it has no subfamily" do
      genus = FactoryGirl.create :genus, :subfamily => nil, :name => 'Myrmicium'
      species = FactoryGirl.create :species, :genus => genus, :name => 'shattucki'
      species.full_label.should == '<i>Myrmicium shattucki</i>'
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      FactoryGirl.create(:species).statistics.should == {}
    end

    it "should handle 1 valid subspecies" do
      species = FactoryGirl.create :species
      subspecies = FactoryGirl.create :subspecies, :species => species
      species.statistics.should == {:extant => {:subspecies => {'valid' => 1}}}
    end

    it "should differentiate between extant and fossil subspecies" do
      species = FactoryGirl.create :species
      subspecies = FactoryGirl.create :subspecies, :species => species
      FactoryGirl.create :subspecies, :species => species, :fossil => true
      species.statistics.should == {
        :extant => {:subspecies => {'valid' => 1}},
        :fossil => {:subspecies => {'valid' => 1}},
      }
    end

    it "should differentiate between extant and fossil subspecies" do
      species = FactoryGirl.create :species
      subspecies = FactoryGirl.create :subspecies, :species => species
      FactoryGirl.create :subspecies, :species => species, :fossil => true
      species.statistics.should == {
        :extant => {:subspecies => {'valid' => 1}},
        :fossil => {:subspecies => {'valid' => 1}},
      }
    end

    it "should handle 1 valid subspecies and 2 synonyms" do
      species = FactoryGirl.create :species
      FactoryGirl.create :subspecies, :species => species
      2.times {FactoryGirl.create :subspecies, :species => species, :status => 'synonym'}
      species.statistics.should == {:extant => {:subspecies => {'valid' => 1, 'synonym' => 2}}}
    end

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

  describe "Creating from a fixup" do
    it "should create the species, and use the passed-in genus" do
      Progress.should_receive(:log).with("FIXUP created species Atta major")
      genus = FactoryGirl.create :genus, name: 'Atta'
      species = Species.create_from_fixup genus_id: genus.id, name: 'Atta major', fossil: true
      species.reload.name.should == 'major'
      species.should_not be_invalid
      species.should be_fossil
      species.genus.should == genus
    end

    it "should handle a subgenus" do
      Progress.should_receive(:log).with("FIXUP created species Atta major")
      genus = FactoryGirl.create :genus, name: 'Atta'
      species = Species.create_from_fixup genus_id: genus.id, name: 'Atta (Spica) major', fossil: true
      species.reload.name.should == 'major'
      species.should_not be_invalid
      species.should be_fossil
      species.genus.should == genus
    end

    it "should handle a subgenus which was a genus at the time" do
      Progress.should_receive(:log).with("FIXUP created species Atta major")
      genus = FactoryGirl.create :genus, name: 'Atta'
      subgenus = FactoryGirl.create :subgenus, name: 'Lasius', genus: genus
      species = Species.create_from_fixup subgenus_id: subgenus.id, name: 'Lasius major'
      species.reload.name.should == 'major'
      species.should_not be_invalid
      species.genus.should == genus
      species.subgenus.should == subgenus
    end

    it "should not raise an error if the passed-in genus doesn't have the same name as the genus name in the species name" do
      genus = FactoryGirl.create :genus, name: 'NotAtta'
      Species.create_from_fixup genus_id: genus.id, name: 'Atta major', fossil: true
      genus.reload.should == genus
    end

    it "should find an existing species" do
      genus = Genus.create! name: 'Atta', status: 'valid'
      existing_species = Species.create! name: 'major', genus: genus, status: 'valid'
      species = Species.create_from_fixup genus_id: genus.id, name: 'Atta major'
      species.reload.should == existing_species
    end
  end

  describe "Importing" do

    it "should work" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'

      species = Species.import(
        genus: genus,
        name: 'major',
        fossil: true,
        protonym: {genus_name: "Atta", species_epithet: 'major',
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        history: ['Atta major as species', 'Atta major as subspecies']
      ).reload
      species.name.should == 'major'
      species.should_not be_invalid
      species.should be_fossil
      species.genus.should == genus
      species.subfamily.should == subfamily
      species.taxonomic_history_items.map(&:taxt).should == ['Atta major as species', 'Atta major as subspecies']

      protonym = species.protonym
      protonym.name.should == 'Atta major'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference
    end

  end

end
