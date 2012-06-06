# coding: UTF-8
require 'spec_helper'

describe SubgenusName do
  it "should exist" do
    name = SubgenusName.new
    name.should be_valid
    name.name = 'Atta'
    name.save!
    name.reload.name.should == 'Atta'
  end
end
