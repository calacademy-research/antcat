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
      FactoryGirl.create(:journal, :name => 'American Bibliographic Proceedings')
      FactoryGirl.create(:journal, :name => 'Playboy')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end

    it "should require matching the first letter" do
      FactoryGirl.create(:journal, :name => 'ABC')
      Journal.search('BC').should == []
    end

    it "should return results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        FactoryGirl.create :journal, :name => name
      end
      2.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Rarely Used')}
      3.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Occasionally Used')}
      4.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Most Used')}
      0.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Never Used')}

      Journal.search.should == ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end

  describe 'validation' do
    it 'should require a name' do
      Journal.new.should_not be_valid
      Journal.new(:name => 'name').should be_valid
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        journal = FactoryGirl.create :journal
        journal.versions.last.event.should == 'create'
      end
    end
  end

  describe "Formatted reference cache" do
    describe "Invalidating the cache" do
      it "should be asked to invalidate the cache when a change occurs" do
        journal = FactoryGirl.create :journal, name: 'Science'
        journal.should_receive :invalidate_formatted_reference_cache
        journal.name = 'Nature'
        journal.save!
      end
      it "should invalidate the cache for the references that use the journal" do
        journal = FactoryGirl.create :journal
        references = []
        (0..2).each do |i|
          if i < 2
            references[i] = FactoryGirl.create :book_reference, journal: journal
          else
            references[i] = FactoryGirl.create :book_reference
          end
          references[i].populate_cache
        end

        references[0].formatted_cache.should_not be_nil
        references[1].formatted_cache.should_not be_nil
        references[2].formatted_cache.should_not be_nil

        journal.invalidate_formatted_reference_cache

        references[0].reload.formatted_cache.should be_nil
        references[1].reload.formatted_cache.should be_nil
        references[2].reload.formatted_cache.should_not be_nil
      end
    end
  end
end
