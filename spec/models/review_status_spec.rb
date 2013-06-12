# coding: UTF-8
require 'spec_helper'

describe ReviewStatus do

  describe "Ddisplay string" do
    it "should return the display string for a review status" do
      ReviewStatus['None'].value.should == 'None'
      ReviewStatus['None'].display_string.should == 'None'
      ReviewStatus['Reviewing'].value.should == 'Reviewing'
      ReviewStatus['Reviewing'].display_string.should == 'Reviewing'
    end
  end

end
