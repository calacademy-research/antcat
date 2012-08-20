# coding: UTF-8
require 'spec_helper'

describe ForwardRefToParentSpecies do
  before do
    @genus = create_genus 'Atta'
  end

  describe "Fixing up forward reference to parent species of subspecies" do
    it "should find a senior synonym subspecies" do
      species = create_species 'Atta molestans', genus: @genus
      subspecies = create_subspecies genus: @genus
      forward_ref = ForwardRefToParentSpecies.create!({
        fixee: subspecies, fixee_attribute: 'species',
        genus: @genus, epithet: 'molestans'
      })
      forward_ref.fixup
      subspecies.reload
      subspecies.species.name.to_s.should == 'Atta molestans'
    end
  end

end
