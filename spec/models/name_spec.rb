require 'spec_helper'

describe Name do
  it "should have a name" do
    Name.new(name_object_name:'Name').name_object_name.should == 'Name'
  end

  describe "Importing" do
    it "should work" do
      name = Name.import 'Atta'
      name.reload.name_object_name.should == 'Atta'
    end
  end
end
