# coding: UTF-8
require 'spec_helper'

describe Journal do
  describe "importing from a new record" do
    it "should create and return the journal" do
      Journal.import(:name => 'Antucopia').name.should == 'Antucopia'
    end

    it "should raise on invalid input" do
      lambda {Journal.import(:name => '')}.should raise_error
    end

    it "should reuse an existing journal" do
      Journal.import(:name => 'Antucopia')
      Journal.import(:name => 'Antucopia')
      Journal.count.should == 1
    end
  end

  describe "searching" do
    it "should do fuzzy matching of journal names" do
      Factory(:journal, :name => 'American Bibliographic Proceedings')
      Factory(:journal, :name => 'Playboy')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end

    it "should require matching the first letter" do
      Factory(:journal, :name => 'ABC')
      Journal.search('BC').should == []
    end

    it "should return results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        Factory :journal, :name => name
      end
      2.times {Factory :article_reference, :journal => Journal.find_by_name('Rarely Used')}
      3.times {Factory :article_reference, :journal => Journal.find_by_name('Occasionally Used')}
      4.times {Factory :article_reference, :journal => Journal.find_by_name('Most Used')}
      0.times {Factory :article_reference, :journal => Journal.find_by_name('Never Used')}

      Journal.search.should == ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end

  describe 'validation' do
    it 'should require a name' do
      Journal.new.should_not be_valid
      Journal.new(:name => 'name').should be_valid
    end
  end

end
