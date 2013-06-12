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

  describe "reviewing?" do
    it "should only consider as 'reviewing' when review status is explicitly set" do
      review_status = ReviewStatus['']
      review_status.should_not be_reviewing

      review_status = ReviewStatus[nil]
      review_status.should_not be_reviewing

      review_status = ReviewStatus['None']
      review_status.should_not be_reviewing

      review_status = ReviewStatus['Reviewing']
      review_status.should be_reviewing
    end
  end

end
