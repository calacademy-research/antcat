# coding: UTF-8
require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = Subgenus.new name: 'Colobopsis'
    colobopsis.should_not be_valid
    colobopsis.genus = Factory :genus, name: 'Camponotus'
    colobopsis.save!
    colobopsis.reload.genus.name.should == 'Camponotus'
  end

  describe "Statistics" do
    it "should have none" do
      Factory(:subgenus).statistics.should be_nil
    end
  end

end
