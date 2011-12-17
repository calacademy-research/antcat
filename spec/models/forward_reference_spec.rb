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

    end
  end

end
