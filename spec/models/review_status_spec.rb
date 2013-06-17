# coding: UTF-8
require 'spec_helper'

describe ReviewStatus do

  describe "Display string" do
    it "should return the display string for a review status" do
      ReviewStatus['None'].value.should == 'None'
      ReviewStatus['None'].display_string.should == 'None'
      ReviewStatus['being reviewed'].value.should == 'being reviewed'
      ReviewStatus['being reviewed'].display_string.should == 'Being reviewed'
    end
  end

  describe "being_reviewed?" do
    it "should only consider as 'being_reviewed' when review status is explicitly set" do
      review_status = ReviewStatus['']
      review_status.should_not be_being_reviewed

      review_status = ReviewStatus[nil]
      review_status.should_not be_being_reviewed

      review_status = ReviewStatus['None']
      review_status.should_not be_being_reviewed

      review_status = ReviewStatus['being reviewed']
      review_status.should be_being_reviewed
    end
  end

end
