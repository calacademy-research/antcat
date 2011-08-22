# coding: UTF-8
require 'spec_helper'

describe Publisher do

  describe "importing" do
    it "should create and return the publisher" do
      publisher = Publisher.import(:name => 'Wiley', :place => 'Chicago')
      publisher.name.should == 'Wiley'
      publisher.place.name.should == 'Chicago'
    end

    it "should reuse an existing publisher" do
      2.times {Publisher.import(:name => 'Wiley', :place => 'Chicago')}
      Publisher.count.should == 1
    end
    
    it "should raise an error if name is supplied but no place" do
      lambda {Publisher.import(:name => 'Wiley')}.should raise_error
    end

  end

  describe "searching" do
    it "should do fuzzy matching of name/place combinations" do
      Publisher.create! :name => 'Wiley', :place => Place.create!(:name => 'Chicago')
      Publisher.create! :name => 'Wiley', :place => Place.create!(:name => 'Toronto')
      Publisher.search('chw').should == ['Chicago: Wiley']
    end
    it "should find a match even if there's no place" do
      Publisher.create! :name => 'Wiley'
      Publisher.search('w').should == ['Wiley']
    end
  end

  describe "importing a string" do
    it "should handle a blank string" do
      Publisher.should_not_receive :import
      Publisher.import_string ''
    end
    it "should parse it correctly" do
      publisher = mock_model Publisher
      Publisher.should_receive(:import).with(:name => 'Houghton Mifflin', :place => 'New York').and_return publisher
      Publisher.import_string('New York: Houghton Mifflin').should == publisher
    end
  end

  describe "representing as a string" do
    it "format name and place" do
      Publisher.create!(:name => "Wiley", :place => Place.create!(:name => 'New York')).to_s.should == 'New York: Wiley'
    end
    it "should format correctly if there is no place" do
      Publisher.create!(:name => "Wiley").to_s.should == 'Wiley'
    end
  end

  describe 'validation' do
    it 'should require a name but not a place' do
      Publisher.new.should_not be_valid
      Publisher.new(:name => 'name').should be_valid
    end
  end

  it 'belongs to a Place' do
    place = Place.create! :name => 'Bogota'
    publisher = Publisher.new :name => 'Wiley', :place => place
  end

end
