# coding: UTF-8
require 'spec_helper'

describe SpeciesEpithetReference do

  describe "Fixing up a reference" do
    it "should look for and find the referenced species" do
      genus = create_genus
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major splendens', genus: genus, species: nil
      attributes = {
        fixee:            subspecies,
        fixee_table:      'taxa',
        fixee_attribute: 'species_id',
        genus:            genus,
        epithet:          'major',
      }
      SpeciesEpithetReference.new(attributes).fixup
      Subspecies.find(subspecies).species.name.to_s.should == 'Atta major'
    end
  end

end
