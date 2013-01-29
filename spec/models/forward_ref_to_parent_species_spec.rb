# coding: UTF-8
require 'spec_helper'

describe ForwardRefToParentSpecies do
  before do
    @genus = create_genus 'Atta'
  end

  describe "Fixing up forward reference to parent species of subspecies" do
    it "should find the parent species" do
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

    it "should adjust the species epithet when the gender has changed" do
      species = create_species 'Atta perpa', genus: @genus
      subspecies_name = FactoryGirl.create :subspecies_name, name: 'Atta perpus rufa', epithets: 'perpus rufa'
      subspecies = create_subspecies genus: @genus, name: subspecies_name
      forward_ref = ForwardRefToParentSpecies.create!({
        fixee: subspecies, fixee_attribute: 'species',
        genus: @genus, epithet: 'perpus'
      })
      forward_ref.fixup
      subspecies.reload
      subspecies.name.to_s.should == 'Atta perpa rufa'
      subspecies.name.epithets.to_s.should == 'perpa rufa'
    end
  end

end
