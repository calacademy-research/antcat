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

      it "should fixup a :type_taxon" do
        family = Factory :family
        forward_reference = ForwardReference.create! :source_id => family.id, :source_attribute => :type_taxon, :target_name => 'Formica'
        forward_reference.fixup
        genus = family.reload.type_taxon
        genus.name.should == 'Formica'
        family.reload.type_taxon_name.should == 'Formica'
      end

      it "should fixup a fossil :type_taxon" do
        family = Factory :family
        forward_reference = ForwardReference.create! source_id: family.id, source_attribute: :type_taxon, target_name: 'Formica', fossil: true
        forward_reference.fixup
        genus = family.reload.type_taxon
        genus.name.should == 'Formica'
        genus.should be_fossil
        family.reload.type_taxon_name.should == '&dagger;Formica'
      end

      it "should fixup a :type_taxon for a subfamily" do
        subfamily = Factory :subfamily
        forward_reference = ForwardReference.create! :source_id => subfamily.id, :source_attribute => :type_taxon, :target_name => 'Formica'
        ForwardReference.fixup
        genus = subfamily.reload.type_taxon
        genus.name.should == 'Formica'
        subfamily.reload.type_taxon_name.should == 'Formica'
      end

      it "should fixup a :type_taxon for a tribe" do
        tribe = Factory :tribe
        forward_reference = ForwardReference.create! :source_id => tribe.id, :source_attribute => :type_taxon, :target_name => 'Atta'
        ForwardReference.fixup
        genus = tribe.reload.type_taxon
        genus.name.should == 'Atta'
        tribe.reload.type_taxon_name.should == 'Atta'
      end

      it "should fixup a :type_taxon for a species" do
        genus = Factory :genus, :name => 'Atta'
        forward_reference = ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => 'Atta major'
        forward_reference.fixup
        species = genus.reload.type_taxon
        species.name.should == 'major'
        species.should == Species.find_by_name('major')
        species.genus.name.should == 'Atta'
        genus.reload.type_taxon_name.should == 'Atta major'
      end

      it "should fixup a :type_taxon for a species with a subgenus" do
        genus = Factory :genus, :name => 'Hypochira'
        forward_reference = ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => 'Formica (Hypochira) subspinosa'
        forward_reference.fixup
        genus.reload
        genus.type_taxon_name.should == 'Formica (Hypochira) subspinosa'
        species = genus.type_taxon
        species.name.should == 'subspinosa'
        species.genus.should == genus
      end

      it "should fixup a :type_taxon for a species with a subgenus, which was a genus at type time" do
        genus = Factory :genus, :name => 'Hypochira'
        subgenus = Factory :subgenus, :genus => genus, name: 'Lasius'
        forward_reference = ForwardReference.create! :source_id => subgenus.id, :source_attribute => :type_taxon, :target_name => 'Lasius major'
        forward_reference.fixup
        subgenus.reload
        subgenus.type_taxon_name.should == 'Lasius major'
        species = subgenus.type_taxon
        species.name.should == 'major'
        species.subgenus.should == subgenus
        species.genus.should == subgenus.genus
        species.subfamily.should == subgenus.genus.subfamily
      end

      it "should complain if it's fixing up something it doesn't understand" do
        genus = Factory :subspecies
        forward_reference = ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => 'Atta major'
        lambda {forward_reference.fixup}.should raise_error
      end

    end
  end

end
