# coding: UTF-8
require 'spec_helper'

describe SpeciesEpithetReference do

  describe "Fixing up a reference" do

    it "should look for and find the referenced species" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major splendens', genus: genus, species: nil
      attributes = {
        fixee:           subspecies,
        fixee_table:     'taxa',
        fixee_attribute: 'species_id',
        genus:           genus,
        epithet:         'major',
      }
      SpeciesEpithetReference.should_receive(:pick_validest).and_return species
      SpeciesEpithetReference.new(attributes).fixup
      Subspecies.find(subspecies).species.name.to_s.should == 'Atta major'
    end

    describe "Picking the validest target" do
      it "should return nil if there is none" do
        targets = []
        SpeciesEpithetReference.pick_validest(targets).should be_nil
      end

      it "should return nil if there is none" do
        targets = nil
        SpeciesEpithetReference.pick_validest(targets).should be_nil
      end

      it "should pick the best target, if there is more than one" do
        invalid_species = create_species status: 'homonym'
        valid_species = create_species status: 'valid'
        targets = [invalid_species, valid_species]
        SpeciesEpithetReference.pick_validest(targets).should == valid_species
      end

      it "should raise an error if there is more than one valid" do
        valid_species = create_species
        another_valid_species = create_species
        targets = [another_valid_species, valid_species]
        -> {SpeciesEpithetReference.pick_validest(targets)}.should raise_error
      end

      it "should not pick the homonym, no matter what" do
        homonym_species = create_species status: 'homonym'
        targets = [homonym_species]
        SpeciesEpithetReference.pick_validest(targets).should be_nil
      end

    end

  end

end
