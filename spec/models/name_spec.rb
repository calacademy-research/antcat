require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  describe "Importing" do
    it "should work" do
      name = Name.import 'Atta'
      name.reload.name.should == 'Atta'
    end
    it "should re-use an existing name" do
      existing_name = FactoryGirl.create :name, name: 'Atta'
      new_name = Name.import 'Atta'
      new_name.should == existing_name
    end
  end

end
