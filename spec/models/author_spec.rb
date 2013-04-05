# coding: UTF-8
require 'spec_helper'

describe Author do
  it "has many names" do
    author = Author.create!
    author.names << FactoryGirl.create(:author_name)
    author.should have(1).name
  end

  describe "sorting by first author name" do
    it "should work" do
      ward = FactoryGirl.create :author_name, :name => 'Ward'
      fisher_b_l = FactoryGirl.create :author_name, :name => 'Fisher, B. L.'
      fisher = FactoryGirl.create :author_name, :name => 'Fisher', :author => fisher_b_l.author 
      bolton = FactoryGirl.create :author_name, :name => 'Bolton'
      Author.sorted_by_name.should == [bolton.author, fisher.author, ward.author]
    end
  end

  describe "converting a list of author names to authors" do
    it "should handle an empty list" do
      Author.find_by_names([]).should == []
    end
    it "should find the authors for the names" do
      bolton = FactoryGirl.create :author_name, :name => 'Bolton'
      fisher = FactoryGirl.create :author_name, :name => 'Fisher'
      Author.find_by_names(['Bolton', 'Fisher']).should =~ [bolton.author, fisher.author]
    end
  end

  describe "Merging authors" do
    it "should make all the names of the passed in authors belong to the same author" do
      first_bolton_author = FactoryGirl.create(:author_name, name: 'Bolton, B').author
      second_bolton_author = FactoryGirl.create(:author_name, name: 'Bolton,B.').author
      Author.count.should == 2
      AuthorName.count.should == 2
      all_names = first_bolton_author.names.dup.concat(second_bolton_author.names).uniq.sort
      Author.merge [first_bolton_author, second_bolton_author]
      all_names.all?{|name| name.author == first_bolton_author}.should be_true
      Author.count.should == 1
      AuthorName.count.should == 2
    end
  end

  describe "Versioning" do
    it "should record versions" do
      author = FactoryGirl.create :author
      author.versions.last.event.should == 'create'
    end
  end

end
