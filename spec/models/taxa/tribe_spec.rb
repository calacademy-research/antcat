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