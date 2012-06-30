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
          {text: [], matched_text: 'hence first available replacement name for'},
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

    it "should handle an unavailable name" do
      SpeciesGroupTaxon.get_status_from_history([
        {unavailable_name: true}
      ]).should == {status: 'unavailable'}
    end

    it "should handle a nomen nudum" do
      SpeciesGroupTaxon.get_status_from_history([
        {nomen_nudum: true}
      ]).should == {status: 'nomen nudum'}
    end

    it "should consider anything with a subspecies list to be valid" do
      SpeciesGroupTaxon.get_status_from_history([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {subspecies: [{species_group_epithet: 'falcifer'}]},
      ]).should == {status: 'valid'}
    end

    describe "Unidentifiable taxa" do
      it "should handle explicit parse" do
        SpeciesGroupTaxon.get_status_from_history([
          {unidentifiable: true}
        ]).should == {status: 'unidentifiable'}
      end
      it "should handle 'unidentifiable' in the text" do
        SpeciesGroupTaxon.get_status_from_history([
          {text: [], matched_text: 'Unidentifiable taxon'},
        ]).should == {status: 'unidentifiable'}
      end
    end

    it "should handle 'homonym' in the text" do
      SpeciesGroupTaxon.get_status_from_history([
        {text: [], matched_text: '[Junior secondary homonym of <i>Cerapachys cooperi</i> Arnold, 1915: 14.]'},
      ]).should == {status: 'homonym'}
    end

    it "should handle an unresolved homonym even if it's a current subspecies" do
      SpeciesGroupTaxon.get_status_from_history([
        {homonym_of: {:unresolved=>true}},
        {currently_subspecies_of: {}},
      ]).should == {status: 'unresolved homonym'}
    end

    it "should a taxon excluded from Formicidae" do
      SpeciesGroupTaxon.get_status_from_history([
        {text: [], matched_text: 'Excluded from Formicidae'}
      ]).should == {status: 'excluded'}
    end

    it "should handle it when information is in matched_text" do
      taxon = SpeciesGroupTaxon.get_status_from_history([
        {text: [], matched_text: ' Unidentifiable taxon, <i>incertae sedis</i> in <i>Acromyrmex</i>: Kempf, 1972a: 16.'}
      ]).should == {status: 'unidentifiable'}
    end

    it "should handle unnecessary replacement name in text" do
      taxon = SpeciesGroupTaxon.get_status_from_history([
        {text: [], matched_text: ' Unnecessary replacement name for <i>Odontomachus tyrannicus</i> Smith, F. 1861b: 44 and hence junior synonym of <i>gladiator</i> Mayr, 1862: 712, the first available replacement name: Brown, 1978c: 556.'}
      ]).should == {status: 'synonym', parent_epithet: 'gladiator'}
    end

  end
end
