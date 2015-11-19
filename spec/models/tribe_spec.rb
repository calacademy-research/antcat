# coding: UTF-8
require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    expect(Tribe.find_by_name('Attini').subfamily).to eq(subfamily)
  end

  it "should have genera, which are its children" do
    attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini')
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Acromyrmex'), :tribe => attini
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :tribe => attini
    expect(attini.genera.map(&:name).map(&:to_s)).to match_array(['Atta', 'Acromyrmex'])
    expect(attini.children).to eq(attini.genera)
  end

  it "should have as its full name just its name" do
    taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    expect(taxon.name.to_s).to eq('Attini')
  end

  it "should have as its label, just its name" do
    taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae'))
    expect(taxon.name.to_html).to eq('Attini')
  end

  describe "Siblings" do

    it "should return itself and its subfamily's other tribes" do
      FactoryGirl.create :tribe
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      another_tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      expect(tribe.siblings).to match_array([tribe, another_tribe])
    end

  end

  describe "Statistics" do
    it "should include the number of genera" do
      tribe = FactoryGirl.create :tribe
      genus = FactoryGirl.create :genus, tribe: tribe
      expect(tribe.statistics).to eq({:extant => {:genera => {'valid' => 1}}})
    end
  end

  describe "Importing" do
    it "should work", pending: true do
      pending("importers no longer used, kept for reference, currently failing")
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

      expect(tribe.name.to_s).to eq('Aneuretini')
      expect(tribe).not_to be_invalid
      expect(tribe).to be_fossil
      expect(tribe.history_items.map(&:taxt)).to eq(['Aneuretini history'])

      expect(tribe.type_name.to_s).to eq('Atta')
      expect(tribe.type_name.rank).to eq('genus')

      protonym = tribe.protonym
      expect(protonym.name.to_s).to eq('Aneuretini')

      authorship = protonym.authorship
      expect(authorship.pages).to eq('6')

      expect(authorship.reference).to eq(reference)

      expect(Update.count).to eq(1)
    end
  end

  describe "Updating" do
    it "should record a change in parent taxon", pending: true do
      pending("importers no longer used, kept for reference, currently failing")
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

      expect(tribe.subfamily).to eq(dolichoderinae)

      aectinae = create_subfamily 'Aectinae'
      data[:subfamily] = aectinae

      tribe = Tribe.import data

      expect(tribe.subfamily).to eq(aectinae)

      expect(Update.count).to eq(2)
      update = Update.find_by_field_name('create')
      expect(update).not_to be_nil

      update = Update.find_by_record_id_and_field_name tribe, :subfamily_id
      expect(update.before).to eq('Dolichoderinae')
      expect(update.after).to eq('Aectinae')
    end

  end

  describe "Updating the parent" do
    it "should assign the subfamily when parent is a tribe" do
      subfamily = FactoryGirl.create :subfamily
      new_subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq(new_subfamily)
    end

    it "should assign the subfamily of its descendants" do
      subfamily = FactoryGirl.create :subfamily
      new_subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      subspecies = create_subspecies species: species, genus: genus
      # test the initial subfamilies
      expect(tribe.subfamily).to eq(subfamily)
      expect(tribe.genera.first.subfamily).to eq(subfamily)
      expect(tribe.genera.first.species.first.subfamily).to eq(subfamily)
      expect(tribe.genera.first.subspecies.first.subfamily).to eq(subfamily)
      # test the updated subfamilies
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq(new_subfamily)
      expect(tribe.genera.first.subfamily).to eq(new_subfamily)
      expect(tribe.genera.first.species.first.subfamily).to eq(new_subfamily)
      expect(tribe.genera.first.subspecies.first.subfamily).to eq(new_subfamily)
    end
  end

end
