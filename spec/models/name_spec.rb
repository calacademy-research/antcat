require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  describe "Making an epithet search set" do

    it "should put the request term first"

    describe "Masculine-feminine" do
      it "should convert between -a and -us" do
        (variants = ['magus', 'maga']).each do |variant|
          Name.make_epithet_set(variant).should =~ variants
        end
      end
      it "should convert between -uus and -ua" do
        (variants = ['equus', 'equa']).each do |variant|
          Name.make_epithet_set(variant).should =~ variants
        end
      end
    end

    it "should convert names deemed identical" do
      (variants = ['lundi', 'lundii']).each do |variant|
        Name.make_epithet_set(variant).should =~ variants
      end
    end

  end

end
