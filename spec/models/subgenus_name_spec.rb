# coding: UTF-8
require 'spec_helper'

describe SubgenusName do
  it "should exist" do
    name = SubgenusName.new
    name.should be_valid
    name.name_object_name = 'Atta'
    name.save!
    NameObject.find(name).name_object_name.should == 'Atta'
  end
end
