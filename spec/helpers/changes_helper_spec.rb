# coding: UTF-8
require 'spec_helper'

describe ChangesHelper do

  describe "Formatting attributes" do
    it "should concatenate attributes into a comma-separated list" do
      genus = create_genus hong: true, nomen_nudum: true
      helper.format_attributes(genus).should == 'Hong, <i>nomen nudum</i>'
    end
    it "should concatenate protonym attributes into a comma-separated list" do
      protonym = FactoryGirl.create :protonym, sic: true, fossil: true
      genus = create_genus protonym: protonym
      helper.format_protonym_attributes(genus).should == 'Fossil, <i>sic</i>'
    end
    it "should include the one type attribute" do
      genus = create_genus type_fossil: true
      helper.format_type_attributes(genus).should == 'Fossil'
    end
  end

end
