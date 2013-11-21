# coding: UTF-8
require 'spec_helper'

describe BiogeographicRegion do

  describe "Instances" do
    it "should have 'em" do
      instances = BiogeographicRegion.instances
      instances.should be_kind_of Array
      instances.size.should_not be_zero
      instances.first.value.should == 'Nearctic'
      instances.first.label.should == 'Nearctic'
    end
  end

  describe "Select options" do
    it "should include the null entry" do
      options_for_select = BiogeographicRegion.options_for_select
      options_for_select.first.should == [nil, nil]
    end
  end

end
