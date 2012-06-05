require 'spec_helper'

describe Name do
  it "should have a name" do
    Name.new(name:('Name')).name.should == 'Name'
  end

  describe "Importing" do
    it "should work" do
      name = Name.import name: 'Atta'
      name.reload.name.should == 'Atta'
    end
  end
end
