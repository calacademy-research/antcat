# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupTaxon do

  it "can have a subfamily" do
    genus = create_genus 'Afropone'
    FactoryGirl.create :species_group_taxon, name: FactoryGirl.create(:name, name: 'championi'), genus: genus
    SpeciesGroupTaxon.find_by_name('championi').subfamily.should == genus.subfamily
  end

  it "doesn't have to have a subfamily" do
    FactoryGirl.create(:species_group_taxon, subfamily: nil).should be_valid
  end

  it "must have a genus" do
    taxon = FactoryGirl.build :species_group_taxon, genus: nil
    taxon.should_not be_valid
    genus = create_genus
    taxon.update_attributes genus: genus
    taxon = SpeciesGroupTaxon.find taxon
    taxon.should be_valid
    taxon.genus.should == genus
  end

  it "can have a subgenus" do
    subgenus = create_subgenus
    taxon = FactoryGirl.create :species_group_taxon, subgenus: subgenus
    SpeciesGroupTaxon.find(taxon).subgenus.should == subgenus
  end

  it "doesn't have to have a subgenus" do
    FactoryGirl.build(:species_group_taxon, subgenus: nil).should be_valid
  end

  it "has its subfamily set from its genus" do
    genus = create_genus
    genus.subfamily.should_not be_nil
    taxon = FactoryGirl.create :species_group_taxon, genus: genus, subfamily: nil
    taxon.subfamily.should == genus.subfamily
  end

  describe "Picking the validest " do
    it "should return nil if there is none" do
      targets = []
      SpeciesGroupTaxon.pick_validest(targets).should be_nil
    end

    it "should return nil if there is none" do
      targets = nil
      SpeciesGroupTaxon.pick_validest(targets).should be_nil
    end

    it "should pick the best target, if there is more than one" do
      invalid_species = create_species status: 'homonym'
      valid_species = create_species status: 'valid'
      targets = [invalid_species, valid_species]
      SpeciesGroupTaxon.pick_validest(targets).should == [valid_species]
    end

    it "should return all the targets if there's no clear choice" do
      valid_species = create_species
      another_valid_species = create_species
      targets = [another_valid_species, valid_species]
      SpeciesGroupTaxon.pick_validest(targets).should =~ [valid_species, another_valid_species]
    end

    it "should not pick the homonym, no matter what" do
      homonym_species = create_species status: 'homonym'
      targets = [homonym_species]
      SpeciesGroupTaxon.pick_validest(targets).should be_nil
    end

  end

  describe "Importing" do
    it "should raise an error if there is no protonym" do
      genus = create_genus 'Afropone'
      -> {
        SpeciesGroupTaxon.import(genus: genus, species_group_epithet: 'orapa', unparseable: 'asdfasdf')
      }.should raise_error SpeciesGroupTaxon::NoProtonymError
    end
  end

  describe "Setting status from history" do
    it "should recognize a synonym_of and set the status accordingly" do
      genus = create_genus 'Atta'
      ferox = create_species 'Atta ferox', genus: genus
      species = create_species 'Atta dyak', genus: genus
      history = [{synonym_ofs: [{species_epithet: 'ferox'}]}]
      species.set_status_from_history history
      species = Species.find species
      species.should be_synonym
      ref = SpeciesGroupForwardRef.first
      ref.fixee.should == species
      ref.genus.should == genus
      ref.epithet.should == 'ferox'
    end
  end

  describe "Getting status from history" do
    it "should consider an empty history as valid" do
      for history in [nil, []]
        SpeciesGroupTaxon.get_status_from_history(history).should ==
          {status: 'valid'}
      end
    end

    describe "Synonyms" do
      it "should recognize a synonym_of" do
        SpeciesGroupTaxon.get_status_from_history([
          {synonym_ofs: [{species_epithet: 'ferox'}]},
        ]).should == {status: 'synonym', parent_epithet: 'ferox'}
      end
      it "should recognize a synonym_of even if it's not the first item in the history" do
        SpeciesGroupTaxon.get_status_from_history([
          {combinations_in: [{genus_name:"Acanthostichus"}]},
          {synonym_ofs: [{species_epithet: 'ferox'}]},
        ]).should == {status: 'synonym', parent_epithet: 'ferox'}
      end
      it "should overrule synonymy with revival from synonymy" do
        SpeciesGroupTaxon.get_status_from_history([
          {synonym_ofs: [{species_epithet: 'ferox'}]},
          {revived_from_synonymy: true},
        ]).should == {status: 'valid'}
      end
      it "should overrule synonymy with raisal to species with revival from synonymy" do
        SpeciesGroupTaxon.get_status_from_history([
          {synonym_ofs: [{species_epithet: 'ferox'}]},
          {raised_to_species: {revived_from_synonymy:true}},
        ]).should == {status: 'valid'}
      end
      it "should stop on 'first available replacement' and make it valid" do
        SpeciesGroupTaxon.get_status_from_history([
          {synonym_ofs: [{species_epithet: 'ferox'}]},
          {text: [{phrase:'hence first available replacement name for', delimiter: ' '}]},
          {homonym_of: {primary_or_secondary: :primary, genus_name: 'Formice'}},
        ]).should == {status: 'valid'}
      end
      it "should overrule synonymy with raisal to species with revival from synonymy" do
        SpeciesGroupTaxon.get_status_from_history([
          {synonym_ofs: [{species_epithet: 'ferox'}]},
          {raised_to_species: {revived_from_synonymy:true}},
        ]).should == {status: 'valid'}
      end
    end

    describe "Unavailable names" do
      it "should get handled" do
        SpeciesGroupTaxon.get_status_from_history([
          {unavailable_name: true}
        ]).should == {status: 'unavailable'}
      end
    end

  end

end
