# coding: UTF-8
require 'spec_helper'

describe Place do

  describe "importing" do
    it "should create and return the place" do
      place = Place.import 'Chicago'
      place.name.should == 'Chicago'
    end

    it "should raise on invalid input" do
      lambda {Place.import(:name => '')}.should raise_error
    end

    it "should reuse an existing place" do
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

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        place = FactoryGirl.create :place
        place.versions.last.event.should == 'create'
      end
    end
  end

  describe "Invalidating the formatted reference cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      place = FactoryGirl.create :place, name: 'Constantinople'
      PlaceObserver.any_instance.should_receive :before_update
      place.name = 'Istanbul'
      place.save!
    end
  end

end
