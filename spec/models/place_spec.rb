require 'spec_helper'

describe Place do

  describe "importing" do
    it "should create and return the place" do
      place = Place.import 'Chicago'
      place.name.should == 'Chicago'
    end

    it "should reuse an existing place" do
      lll{'Place.all'}
      Place.count.should == 0
      2.times {Place.import('Chicago')}
      Place.count.should == 1
    end
  end

  describe 'validation' do
    it 'should require a name' do
      Place.new.should_not be_valid
      Place.new(:name => 'name').should be_valid
    end
  end

end
