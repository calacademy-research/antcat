# coding: UTF-8
require 'spec_helper'

describe ChangesHelper do

  describe "Formatting attributes" do
    it "should concatenate attributes into a comma-separated list" do
      genus = create_genus hong: true, nomen_nudum: true
      helper.format_change_attributes(genus).should == 'Hong, <i>nomen nudum</i>'
    end
  end
end
