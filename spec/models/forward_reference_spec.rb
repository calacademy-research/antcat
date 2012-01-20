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
      end

      it "should fixup a fossil :type_taxon" do
        family = Factory :family
        forward_reference = ForwardReference.create! source_id: family.id, source_attribute: :type_taxon, target_name: 'Formica', fossil: true

        forward_reference.fixup

        genus = family.reload.type_taxon
        genus.name.should == 'Formica'
        genus.should be_fossil
      end

      it "should fixup a :type_taxon for a species" do
        genus = Factory :genus, :name => 'Atta'
        forward_reference = ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => 'Atta major'

        forward_reference.fixup

        species = genus.reload.type_taxon
        species.name.should == 'major'
        species.should == Species.find_by_name('major')
        species.genus.name.should == 'Atta'
      end

      it "should complain if it's fixing up something it doesn't understand" do
        genus = Factory :subspecies
        forward_reference = ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => 'Atta major'

        lambda {forward_reference.fixup}.should raise_error
      end

    end
  end

end
