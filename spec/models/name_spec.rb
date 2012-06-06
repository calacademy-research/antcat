require 'spec_helper'

describe NameObject do
  it "should have a name" do
    NameObject.new(name_object_name:'NameObject').name_object_name.should == 'NameObject'
  end

  describe "Importing" do
    it "should work" do
      name = NameObject.import 'Atta'
      name.reload.name_object_name.should == 'Atta'
    end
  end
end
