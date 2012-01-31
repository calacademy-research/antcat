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
        family = Factory :family
        forward_reference = ForwardReference.create! :source_id => family.id, :target_name => 'Formica'
        forward_reference.fixup
        family.reload
        family.type_taxon_rank.should == 'genus'
        family.type_taxon_name.should == 'Formica'
      end

      it "should fixup a type taxon for a subfamily" do
        subfamily = Factory :subfamily
        forward_reference = ForwardReference.create! :source_id => subfamily.id, :target_name => 'Formica'
        ForwardReference.fixup
        subfamily.reload
        subfamily.type_taxon_rank.should == 'genus'
        subfamily.type_taxon_name.should == 'Formica'
      end

      it "should fixup a type taxon for a tribe" do
        tribe = Factory :tribe
        forward_reference = ForwardReference.create! :source_id => tribe.id, :target_name => 'Atta'
        ForwardReference.fixup
        tribe.reload
        tribe.type_taxon_rank.should == 'genus'
        tribe.type_taxon_name.should == 'Atta'
      end

      it "should fixup a type taxon for a species" do
        genus = Factory :genus, :name => 'Atta'
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Atta major'
        forward_reference.fixup
        genus.reload
        genus.type_taxon_rank.should == 'species'
        genus.type_taxon_name.should == 'Atta major'
      end

      it "should fixup a type taxon for a species with a subgenus" do
        genus = Factory :genus, :name => 'Hypochira'
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Formica (Hypochira) subspinosa'
        forward_reference.fixup
        genus.reload
        genus.type_taxon_rank.should == 'species'
        genus.type_taxon_name.should == 'Formica (Hypochira) subspinosa'
      end

      it "should fixup a type taxon for a species with a subgenus, which was a genus at type time" do
        genus = Factory :genus, :name => 'Hypochira'
        subgenus = Factory :subgenus, :genus => genus, name: 'Lasius'
        forward_reference = ForwardReference.create! :source_id => subgenus.id, :target_name => 'Lasius major'
        forward_reference.fixup
        subgenus.reload
        subgenus.type_taxon_rank.should == 'species'
        subgenus.type_taxon_name.should == 'Lasius major'
      end

      it "should complain if it's fixing up something it doesn't understand" do
        genus = Factory :subspecies
        forward_reference = ForwardReference.create! :source_id => genus.id, :target_name => 'Atta major'
        lambda {forward_reference.fixup}.should raise_error
      end

    end
  end

end
