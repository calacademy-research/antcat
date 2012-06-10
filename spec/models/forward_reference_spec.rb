# coding: UTF-8
require 'spec_helper'

describe ForwardReference do

  describe "Fixing up" do
    describe "Fixing up all forward references" do
      it "should do nothing if the table is empty" do
        ForwardReference.fixup
      end

      it "should call each's fixup method" do
        first = mock
        second = mock
        ForwardReference.should_receive(:all).and_return [first, second]
        first.should_receive(:fixup)
        second.should_receive(:fixup)

        ForwardReference.fixup
      end
    end

    describe "Fixing up one reference" do

      it "should fixup a type taxon" do
        family = FactoryGirl.create :family
        forward_reference = ForwardReference.create! :source_id => family.id, :target_name => 'Formica'
        forward_reference.fixup
        family.reload
        family.type_taxon_rank.should == 'genus'
        family.type_taxon_name.should == 'Formica'
      end

      it "should fixup a type taxon for a subfamily" do
        subfamily = FactoryGirl.create :subfamily
        forward_reference = ForwardReference.create! :source_id => subfamily.id, :target_name => 'Formica'
        ForwardReference.fixup
        subfamily.reload
        subfamily.type_taxon_rank.should == 'genus'
        subfamily.type_taxon_name.should == 'Formica'
      end

      it "should fixup a type taxon for a tribe" do
        tribe = FactoryGirl.create :tribe
        forward_reference = ForwardReference.create! :source_id => tribe.id, :target_name => 'Atta'
        ForwardReference.fixup
        tribe.reload
        tribe.type_taxon_rank.should == 'genus'
        tribe.type_taxon_name.should == 'Atta'
      end

      it "should fixup a type taxon for a species" do
        genus = FactoryGirl.create :genus, name_object: FactoryGirl.create(:name, name: 'Atta')
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Atta major'
        forward_reference.fixup
        genus.reload
        genus.type_taxon_rank.should == 'species'
        genus.type_taxon_name.should == 'Atta major'
      end

      it "should fixup a type taxon for a species with a subgenus" do
        genus = FactoryGirl.create :genus, name_object: FactoryGirl.create(:name, name: 'Hypochira')
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Formica (Hypochira) subspinosa'
        forward_reference.fixup
        genus.reload
        genus.type_taxon_rank.should == 'species'
        genus.type_taxon_name.should == 'Formica (Hypochira) subspinosa'
      end

      it "should fixup a type taxon for a species with a subgenus, which was a genus at type time" do
        genus = FactoryGirl.create :genus, name_object: FactoryGirl.create(:name, name: 'Hypochira')
        subgenus = FactoryGirl.create :subgenus, name_object: FactoryGirl.create(:name, name: 'Lasius'), :genus => genus
        forward_reference = ForwardReference.create! :source_id => subgenus.id, :target_name => 'Lasius major'
        forward_reference.fixup
        subgenus.reload
        subgenus.type_taxon_rank.should == 'species'
        subgenus.type_taxon_name.should == 'Lasius major'
      end

      it "should complain if it's fixing up something it doesn't understand" do
        genus = FactoryGirl.create :subspecies
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Atta major'
        lambda {forward_reference.fixup}.should raise_error
      end

      it "should fixup a senior synonym" do
        genus = FactoryGirl.create :genus
        species_name = FactoryGirl.create(:species_name, name: 'minor', genus_group_name: genus.name_object)
        junior_synonym = FactoryGirl.create :species, genus: genus
        senior_synonym = FactoryGirl.create :species, name_object: species_name, genus: genus
        forward_reference = ForwardReference.create! :source_id => junior_synonym.id, :target_name => 'minor', target_parent: genus.id
        forward_reference.fixup
        junior_synonym.reload
        junior_synonym.should be_synonym_of senior_synonym
      end

    end
  end

end
