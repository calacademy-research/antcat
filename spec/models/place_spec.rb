require 'spec_helper'

describe Place do

  describe "importing" do
    it "should create and return the place" do
      place = Place.import 'Chicago'
      expect(place.name).to eq('Chicago')
    end

    it "should raise on invalid input" do
      expect {Place.import(:name => '')}.to raise_error
    end

    it "should reuse an existing place" do
      expect(Place.count).to eq(0)
      2.times {Place.import('Chicago')}
      expect(Place.count).to eq(1)
    end
  end

  describe 'validation' do
    it 'should require a name' do
      expect(Place.new).not_to be_valid
      expect(Place.new(:name => 'name')).to be_valid
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        place = FactoryGirl.create :place
        expect(place.versions.last.event).to eq('create')
      end
    end
  end

end
