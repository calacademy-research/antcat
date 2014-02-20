# coding: UTF-8
require 'spec_helper'

describe Genus do

  it "should have a tribe" do
    attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :tribe => attini
    Genus.find_by_name('Atta').tribe.should == attini
  end

  it "should have species, which are its children" do
    atta = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
    FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'robusta'), :genus => atta
    FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'saltensis'), :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.species.map(&:name).map(&:to_s).should =~ ['robusta', 'saltensis']
    atta.children.should == atta.species
  end

  it "should have subspecies" do
    genus = FactoryGirl.create :genus
    FactoryGirl.create :subspecies, genus: genus
    genus.should have(1).subspecies
  end

  it "should use the species's' genus, if nec." do
    genus = FactoryGirl.create :genus
    species = FactoryGirl.create :species, genus: genus
    FactoryGirl.create :subspecies, species: species, genus: nil
    genus.should have(1).subspecies
  end

  it "should have subgenera" do
    atta = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
    FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'robusta'), :genus => atta
    FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'saltensis'), :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.subgenera.map(&:name).map(&:to_s).should =~ ['robusta', 'saltensis']
  end

  describe "Statistics" do

    it "should handle 0 children" do
      genus = FactoryGirl.create :genus
      genus.statistics.should == {}
    end

    it "should handle 1 valid species" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, :genus => genus
      genus.statistics.should == {:extant => {:species => {'valid' => 1}}}
    end

    it "should ignore original combinations" do
      genus = create_genus
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, status: 'original combination', genus: genus
      genus.statistics.should == {:extant => {:species => {'valid' => 1}}}
    end

    it "should handle 1 valid species and 2 synonyms" do
      genus = FactoryGirl.create :genus
      FactoryGirl.create :species, :genus => genus
      2.times {FactoryGirl.create :species, :genus => genus, :status => 'synonym'}
      genus.statistics.should == {:extant => {:species => {'valid' => 1, 'synonym' => 2}}}
    end

    it "should handle 1 valid species with 2 valid subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      2.times {FactoryGirl.create :subspecies, species: species, genus: genus}
      genus.statistics.should == {extant: {species: {'valid' => 1}, subspecies: {'valid' => 2}}}
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      fossil_species = FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species
      FactoryGirl.create :subspecies, genus: genus, species: fossil_species, fossil: true
      genus.statistics.should == {
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      }
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      fossil_species = FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species
      FactoryGirl.create :subspecies, genus: genus, species: fossil_species, fossil: true
      genus.statistics.should == {
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      }
    end

  end

  describe "Without subfamily" do
    it "should just return the genera with no subfamily" do
      cariridris = FactoryGirl.create :genus, :subfamily => nil
      atta = FactoryGirl.create :genus
      Genus.without_subfamily.all.should == [cariridris]
    end
  end

  describe "Without tribe" do
    it "should just return the genera with no tribe" do
      tribe = FactoryGirl.create :tribe
      cariridris = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      atta = FactoryGirl.create :genus, :subfamily => tribe.subfamily, :tribe => nil
      Genus.without_tribe.all.should == [atta]
    end
  end

  describe "Siblings" do

    it "should return itself when there are no others" do
      FactoryGirl.create :genus
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      genus.siblings.should == [genus]
    end

    it "should return itself and its tribe's other genera" do
      FactoryGirl.create :genus
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      another_genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      genus.siblings.should =~ [genus, another_genus]
    end

    it "when there's no subfamily, should return all the genera with no subfamilies" do
      FactoryGirl.create :genus
      genus = FactoryGirl.create :genus, :subfamily => nil, :tribe => nil
      another_genus = FactoryGirl.create :genus, :subfamily => nil, :tribe => nil
      genus.siblings.should =~ [genus, another_genus]
    end

    it "when there's no tribe, return the other genera in its subfamily without tribes" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      FactoryGirl.create :genus, :tribe => tribe, :subfamily => subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => nil
      another_genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => nil
      genus.siblings.should =~ [genus, another_genus]
    end

  end

  describe "Species group descendants" do
    before do
      @genus = create_genus
    end
    it "should return an empty array if there are none" do
      @genus.species_group_descendants.should == []
    end
    it "should return all the species" do
      species = create_species genus: @genus
      @genus.species_group_descendants.should == [species]
    end
    it "should return all the species and subspecies of the genus" do
      species = create_species genus: @genus
      subgenus = create_subgenus genus: @genus
      subspecies = create_subspecies genus: @genus, species: species
      @genus.species_group_descendants.should =~ [species, subspecies]
    end
  end

  describe "Importing" do

    it "should work" do
      subfamily = FactoryGirl.create :subfamily
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import(
        subfamily: subfamily,
        genus_name: 'Atta',
        fossil: true,
        protonym: {genus_name: "Atta",
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {genus_name: 'Atta', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        history: ["Atta as genus", "Atta as species"]
      ).reload
      genus.name.to_s.should == 'Atta'
      genus.name.epithet.should == 'Atta'
      genus.should_not be_invalid
      genus.should be_fossil
      genus.subfamily.should == subfamily
      genus.history_items.map(&:taxt).should == ['Atta as genus', 'Atta as species']
      genus.type_taxt.should == ', by monotypy'

      protonym = genus.protonym
      protonym.name.to_s.should == 'Atta'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference

      Update.count.should == 1
      update = Update.find_by_record_id genus.id
      update.name.should == 'Atta'
      update.class_name.should == 'Genus'
      update.field_name.should == 'create'
      update.name.should == 'Atta'
    end

    it "save the subgenus part correctly" do
      FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import({
        genus_name: 'Atta',
        protonym: {genus_name: "Atta", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {genus_name: 'Atta', subgenus_epithet: 'Solis', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        history: [],
      })
      Genus.find(genus).type_name.to_s.should == 'Atta major'
    end

    it "should not mind if there's no type" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import({
        :genus_name => 'Atta',
        :protonym => {
          :genus_name => "Atta",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :history => ["Atta as genus", "Atta as species"]
      }).reload
      genus.type_taxt.should be_nil
    end

    it "should create synonyms" do
      reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Latreille')], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      senior = create_genus 'Aneuretus'
      junior = Genus.import(
        genus_name: 'Eciton',
        protonym: {
          genus_name: 'Eciton',
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        attributes: {synonym_of: senior},
        history: []
      )
      junior.junior_synonyms.should be_empty
      junior.senior_synonyms.should == [senior]
      senior.junior_synonyms.should == [junior]
      senior.senior_synonyms.should be_empty
    end

    it "should make sure the type-species is fixed up to point to the genus and not just to any genus with the same name" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import({
        :genus_name => 'Myrmicium',
        :protonym => {
          :genus_name => "Myrmicium",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_species => {:genus_name => 'Myrmicium', :species_epithet => 'heeri'},
        :history => []
      })
      genus = Genus.find genus
      genus.type_name.to_s.should == 'Myrmicium heeri'
      genus.type_name.rank.should == 'species'
    end

    describe "Manual 'importing'" do
      it "should import Formicites" do
        Genus.import_formicites
        genus = Genus.find_by_name 'Formicites'
        genus.status.should == 'collective group name'
      end
    end

  end

  describe "Updating" do
    before do
      FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
      FactoryGirl.create :article_reference, bolton_key_cache: 'Fisher 2004'
    end

    describe "Updating" do
      before do
        @dolichoderinae = create_subfamily 'Dolichoderinae'
        @dolichoderini = create_tribe 'Dolichoderini', subfamily: @dolichoderinae
      end

      it "should record a change in parent taxon" do
        data = {
          genus_name: 'Atta',
          protonym: {genus_name: 'Atta', authorship: [{author_names: ['Latreille'], year: '1809', pages: '7'}]},
          type_species: {genus_name: 'Atta', species_epithet: 'Atta major'},
          history: [],
          subfamily: @dolichoderinae,
          tribe: @dolichoderini,
        }
        genus = Genus.import data
        Taxon.count.should == 3
        genus.subfamily.should == @dolichoderinae
        genus.tribe.should == @dolichoderini

        aectinae = create_subfamily 'Aectinae'
        aectini = create_tribe 'Aectini', subfamily: aectinae
        data[:subfamily] = aectinae
        data[:tribe] = aectini

        genus = Genus.import data
        Taxon.count.should == 5

        genus.subfamily.should == aectinae
        genus.tribe.should == aectini

        Update.count.should == 3

        update = Update.find_by_record_id_and_field_name genus, :subfamily_id
        update.before.should == 'Dolichoderinae'
        update.after.should == 'Aectinae'

        update = Update.find_by_record_id_and_field_name genus, :subfamily_id
        update.before.should == 'Dolichoderinae'
        update.after.should == 'Aectinae'
      end
    end

    it "should record a change in incertae sedis" do
      data = {
        genus_name: 'Atta',
        protonym: {genus_name: 'Atta',
                   authorship:
                   [{author_names: ['Latreille'], year: '1809', pages: '7'}]},
        type_species: {genus_name: 'Atta', species_epithet: 'Atta major'},
        history: [],
        subfamily: create_subfamily,
        tribe: create_tribe,
      }
      genus = Genus.import data
      genus.incertae_sedis_in.should be_nil

      data[:attributes] = {}
      data[:attributes][:incertae_sedis_in] = 'subfamily'
      genus = Genus.import data

      genus.incertae_sedis_in.should == 'subfamily'
    end

    it "should record a change in hong" do
      data = {
        genus_name: 'Atta',
        protonym: {genus_name: 'Atta',
                   authorship:
                   [{author_names: ['Latreille'], year: '1809', pages: '7'}]},
        type_species: {genus_name: 'Atta', species_epithet: 'Atta major'},
        history: [],
        subfamily: create_subfamily,
        tribe: create_tribe,
      }
      genus = Genus.import data
      genus.hong.should be_false

      data[:hong] = true
      genus = Genus.import data
      genus.hong.should be_true
    end
  end

  describe "Parent" do
    it "should be nil, if there's no subfamily" do
      genus = create_genus subfamily: nil, tribe: nil
      genus.parent.should be_nil
    end
    it "should refer to the subfamily, if there is one" do
      subfamily = create_subfamily
      genus = create_genus subfamily: subfamily, tribe: nil
      genus.parent.should == subfamily
    end
    it "should refer to the tribe, if there is one" do
      tribe = create_tribe
      genus = create_genus subfamily: tribe.subfamily, tribe: tribe
      genus.parent.should == tribe
    end
  end

  describe "Assiging the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      protonym = FactoryGirl.create :protonym
      genus = Genus.create! name: FactoryGirl.create(:name, name: 'Aneuretus'), protonym: protonym
      genus.parent = tribe
      genus.tribe.should == tribe
      genus.subfamily.should == subfamily
    end
  end
  describe "Updating the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      protonym = FactoryGirl.create :protonym
      genus = Genus.create! name: FactoryGirl.create(:name, name: 'Aneuretus'), protonym: protonym
      genus.update_parent tribe
      genus.tribe.should == tribe
      genus.subfamily.should == subfamily
    end
    it "should assign the subfamily when the tribe is nil, and set the tribe to nil" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      genus.update_parent subfamily
      genus.tribe.should == nil
      genus.subfamily.should == subfamily
    end
  end
end
