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

    describe "Creating the right subclass" do
      it "should create a regular Name for most things" do
        name = Name.import 'Formicidae', family_name: 'Formicidae'
        name.should be_kind_of Name
      end
      it "should create an object of the appropriate subclass" do
        name = Name.import 'Atta', genus_name: 'Atta'
        name.should be_kind_of GenusName
      end
    end

  end

end
