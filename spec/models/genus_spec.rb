# coding: UTF-8
require 'spec_helper'

describe Genus do
  PaperTrail.enabled = true
  it "should have a tribe" do
    attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :tribe => attini
    expect(Genus.find_by_name('Atta').tribe).to eq(attini)
  end

  it "should have species, which are its children" do
    atta = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
    FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'robusta'), :genus => atta
    FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'saltensis'), :genus => atta
    atta = Genus.find_by_name('Atta')
    expect(atta.species.map(&:name).map(&:to_s)).to match_array(['robusta', 'saltensis'])
    expect(atta.children).to eq(atta.species)
  end

  it "should have subspecies" do
    genus = FactoryGirl.create :genus
    FactoryGirl.create :subspecies, genus: genus
    expect(genus.subspecies.count).to eq(1)
  end

  it "should use the species's' genus, if nec." do
    genus = FactoryGirl.create :genus
    species = FactoryGirl.create :species, genus: genus
    FactoryGirl.create :subspecies, species: species, genus: nil
    expect(genus.subspecies.count).to eq(1)
  end

  it "should have subgenera" do
    atta = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta')
    FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'robusta'), :genus => atta
    FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'saltensis'), :genus => atta
    atta = Genus.find_by_name('Atta')
    expect(atta.subgenera.map(&:name).map(&:to_s)).to match_array(['robusta', 'saltensis'])
  end

  describe "Statistics" do

    it "should handle 0 children" do
      genus = FactoryGirl.create :genus
      expect(genus.statistics).to eq({})
    end

    it "should handle 1 valid species" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, :genus => genus
      expect(genus.statistics).to eq({:extant => {:species => {'valid' => 1}}})
    end

    it "should ignore original combinations" do
      genus = create_genus
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, status: 'original combination', genus: genus
      expect(genus.statistics).to eq({:extant => {:species => {'valid' => 1}}})
    end

    it "should handle 1 valid species and 2 synonyms" do
      genus = FactoryGirl.create :genus
      FactoryGirl.create :species, :genus => genus
      2.times {FactoryGirl.create :species, :genus => genus, :status => 'synonym'}
      expect(genus.statistics).to eq({:extant => {:species => {'valid' => 1, 'synonym' => 2}}})
    end

    it "should handle 1 valid species with 2 valid subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      2.times {FactoryGirl.create :subspecies, species: species, genus: genus}
      expect(genus.statistics).to eq({extant: {species: {'valid' => 1}, subspecies: {'valid' => 2}}})
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      fossil_species = FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species
      FactoryGirl.create :subspecies, genus: genus, species: fossil_species, fossil: true
      expect(genus.statistics).to eq({
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      })
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = FactoryGirl.create :genus
      species = FactoryGirl.create :species, genus: genus
      fossil_species = FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: species
      FactoryGirl.create :subspecies, genus: genus, species: fossil_species, fossil: true
      expect(genus.statistics).to eq({
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      })
    end

  end

  describe "Without subfamily" do
    it "should just return the genera with no subfamily" do
      cariridris = FactoryGirl.create :genus, :subfamily => nil
      atta = FactoryGirl.create :genus
      expect(Genus.without_subfamily.all).to eq([cariridris])
    end
  end

  describe "Without tribe" do
    it "should just return the genera with no tribe" do
      tribe = FactoryGirl.create :tribe
      cariridris = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      atta = FactoryGirl.create :genus, :subfamily => tribe.subfamily, :tribe => nil
      expect(Genus.without_tribe.all).to eq([atta])
    end
  end

  describe "Siblings" do

    it "should return itself when there are no others" do
      FactoryGirl.create :genus
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      expect(genus.siblings).to eq([genus])
    end

    it "should return itself and its tribe's other genera" do
      FactoryGirl.create :genus
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      another_genus = FactoryGirl.create :genus, :tribe => tribe, :subfamily => tribe.subfamily
      expect(genus.siblings).to match_array([genus, another_genus])
    end

    it "when there's no subfamily, should return all the genera with no subfamilies" do
      FactoryGirl.create :genus
      genus = FactoryGirl.create :genus, :subfamily => nil, :tribe => nil
      another_genus = FactoryGirl.create :genus, :subfamily => nil, :tribe => nil
      expect(genus.siblings).to match_array([genus, another_genus])
    end

    it "when there's no tribe, return the other genera in its subfamily without tribes" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      FactoryGirl.create :genus, :tribe => tribe, :subfamily => subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => nil
      another_genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => nil
      expect(genus.siblings).to match_array([genus, another_genus])
    end

  end

  describe "Species group descendants" do
    before do
      @genus = create_genus
    end
    it "should return an empty array if there are none" do
      expect(@genus.species_group_descendants).to eq([])
    end
    it "should return all the species" do
      species = create_species genus: @genus
      expect(@genus.species_group_descendants).to eq([species])
    end
    it "should return all the species and subspecies of the genus" do
      species = create_species genus: @genus
      subgenus = create_subgenus genus: @genus
      subspecies = create_subspecies genus: @genus, species: species
      expect(@genus.species_group_descendants).to match_array([species, subspecies])
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
      expect(genus.name.to_s).to eq('Atta')
      expect(genus.name.epithet).to eq('Atta')
      expect(genus).not_to be_invalid
      expect(genus).to be_fossil
      expect(genus.subfamily).to eq(subfamily)
      expect(genus.history_items.map(&:taxt)).to eq(['Atta as genus', 'Atta as species'])
      expect(genus.type_taxt).to eq(', by monotypy')

      protonym = genus.protonym
      expect(protonym.name.to_s).to eq('Atta')

      authorship = protonym.authorship
      expect(authorship.pages).to eq('124')

      expect(authorship.reference).to eq(reference)

      expect(Update.count).to eq(1)
      update = Update.find_by_record_id genus.id
      expect(update.name).to eq('Atta')
      expect(update.class_name).to eq('Genus')
      expect(update.field_name).to eq('create')
      expect(update.name).to eq('Atta')
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
      expect(Genus.find(genus.id).type_name.to_s).to eq('Atta major')
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
      expect(genus.type_taxt).to be_nil
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
      expect(junior.junior_synonyms).to be_empty
      expect(junior.senior_synonyms).to eq([senior])
      expect(senior.junior_synonyms).to eq([junior])
      expect(senior.senior_synonyms).to be_empty
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
      genus = Genus.find genus.id
      expect(genus.type_name.to_s).to eq('Myrmicium heeri')
      expect(genus.type_name.rank).to eq('species')
    end

    describe "Manual 'importing'" do
      it "should import Formicites" do
        Genus.import_formicites
        genus = Genus.find_by_name 'Formicites'
        expect(genus.status).to eq('collective group name')
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
        expect(Taxon.count).to eq(3)
        expect(genus.subfamily).to eq(@dolichoderinae)
        expect(genus.tribe).to eq(@dolichoderini)

        aectinae = create_subfamily 'Aectinae'
        aectini = create_tribe 'Aectini', subfamily: aectinae
        data[:subfamily] = aectinae
        data[:tribe] = aectini

        genus = Genus.import data
        expect(Taxon.count).to eq(5)

        expect(genus.subfamily).to eq(aectinae)
        expect(genus.tribe).to eq(aectini)

        expect(Update.count).to eq(3)

        update = Update.find_by_record_id_and_field_name genus, :subfamily_id
        expect(update.before).to eq('Dolichoderinae')
        expect(update.after).to eq('Aectinae')

        update = Update.find_by_record_id_and_field_name genus, :subfamily_id
        expect(update.before).to eq('Dolichoderinae')
        expect(update.after).to eq('Aectinae')
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
      expect(genus.incertae_sedis_in).to be_nil

      data[:attributes] = {}
      data[:attributes][:incertae_sedis_in] = 'subfamily'
      genus = Genus.import data

      expect(genus.incertae_sedis_in).to eq('subfamily')
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
      expect(genus.hong).to be_falsey

      data[:hong] = true
      genus = Genus.import data
      expect(genus.hong).to be_truthy
    end
  end

  describe "Parent" do
    it "should be nil, if there's no subfamily" do
      genus = create_genus subfamily: nil, tribe: nil
      expect(genus.parent).to be_nil
    end
    it "should refer to the subfamily, if there is one" do
      subfamily = create_subfamily
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(genus.parent).to eq(subfamily)
    end
    it "should refer to the tribe, if there is one" do
      tribe = create_tribe
      genus = create_genus subfamily: tribe.subfamily, tribe: tribe
      expect(genus.parent).to eq(tribe)
    end
  end

  describe "Assiging the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      protonym = FactoryGirl.create :protonym


      genus = create_genus 'Aneuretus', protonym: protonym


      genus.parent = tribe
      expect(genus.tribe).to eq(tribe)
      expect(genus.subfamily).to eq(subfamily)
    end
  end
  describe "Updating the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      protonym = FactoryGirl.create :protonym
      genus = create_genus 'Aneuretus', protonym: protonym

      genus.update_parent tribe
      expect(genus.tribe).to eq(tribe)
      expect(genus.subfamily).to eq(subfamily)
    end
    it "should assign the subfamily when the tribe is nil, and set the tribe to nil" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      genus.update_parent subfamily
      expect(genus.tribe).to eq(nil)
      expect(genus.subfamily).to eq(subfamily)
    end
    it "should clear both subfamily and tribe when the new parent is nil" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      genus.update_parent nil
      expect(genus.tribe).to eq(nil)
      expect(genus.subfamily).to eq(nil)
    end

    it "should assign the subfamily of its descendants" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      new_subfamily = FactoryGirl.create :subfamily
      new_tribe = FactoryGirl.create :tribe, subfamily: new_subfamily
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      subspecies = create_subspecies species: species, genus: genus
      # test the initial subfamilies
      expect(genus.subfamily).to eq(subfamily)
      expect(genus.species.first.subfamily).to eq(subfamily)
      expect(genus.subspecies.first.subfamily).to eq(subfamily)
      # test the updated subfamilies
      genus.update_parent new_tribe
      expect(genus.subfamily).to eq(new_subfamily)
      expect(genus.species.first.subfamily).to eq(new_subfamily)
      expect(genus.subspecies.first.subfamily).to eq(new_subfamily)
    end
  end
end
