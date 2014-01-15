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

  describe "Formatted reference cache" do
    describe "Invalidating the cache" do
      it "should be asked to invalidate the cache when a change occurs" do
        place = FactoryGirl.create :place, name: 'Constantinople'
        place.should_receive :invalidate_formatted_reference_cache
        place.name = 'Istanbul'
        place.save!
      end
      it "should invalidate the cache for the references that use the place" do
        place = FactoryGirl.create :place
        publisher = FactoryGirl.create :publisher, place: place
        references = []
        (0..2).each do |i|
          if i < 2
            references[i] = FactoryGirl.create :book_reference, publisher: publisher
          else
            references[i] = FactoryGirl.create :book_reference
          end
          references[i].populate_cache
        end

        references[0].formatted_cache.should_not be_nil
        references[1].formatted_cache.should_not be_nil
        references[2].formatted_cache.should_not be_nil

        place.invalidate_formatted_reference_cache

        references[0].reload.formatted_cache.should be_nil
        references[1].reload.formatted_cache.should be_nil
        references[2].reload.formatted_cache.should_not be_nil
      end
    end
  end
end
