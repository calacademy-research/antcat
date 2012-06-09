require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

end
