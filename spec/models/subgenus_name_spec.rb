# coding: UTF-8
require 'spec_helper'

describe SubgenusName do
  it "should exist" do
    name = SubgenusName.new
    name.should_not be_valid
    name.name = 'Atta'
    name.save!
    Name.find(name).name.should == 'Atta'
  end
end
