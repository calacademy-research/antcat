# coding: UTF-8
require 'spec_helper'

describe Author do
  it "has many names" do
    author = Author.create!
    author.names << FactoryGirl.create(:author_name)
    expect(author.names.size).to eq(1)
  end

  describe "sorting by first author name" do
    it "should work" do
      ward = FactoryGirl.create :author_name, :name => 'Ward'
      fisher_b_l = FactoryGirl.create :author_name, :name => 'Fisher, B. L.'
      fisher = FactoryGirl.create :author_name, :name => 'Fisher', :author => fisher_b_l.author
      bolton = FactoryGirl.create :author_name, :name => 'Bolton'
      expect(Author.sorted_by_name).to eq([bolton.author, fisher.author, ward.author])
    end
  end

  describe "converting a list of author names to authors" do
    it "should handle an empty list" do
      expect(Author.find_by_names([])).to eq([])
    end
    it "should find the authors for the names" do
      bolton = FactoryGirl.create :author_name, :name => 'Bolton'
      fisher = FactoryGirl.create :author_name, :name => 'Fisher'
      expect(Author.find_by_names(['Bolton', 'Fisher'])).to match_array([bolton.author, fisher.author])
    end
  end

  describe "Merging authors" do
    it "should make all the names of the passed in authors belong to the same author" do
      first_bolton_author = FactoryGirl.create(:author_name, name: 'Bolton, B').author
      second_bolton_author = FactoryGirl.create(:author_name, name: 'Bolton,B.').author
      expect(Author.count).to eq(2)
      expect(AuthorName.count).to eq(2)

      all_names = (first_bolton_author.names + second_bolton_author.names).uniq.sort

      Author.merge [first_bolton_author, second_bolton_author]
      expect(all_names.all?{|name| name.author == first_bolton_author}).to be_truthy

      expect(Author.count).to eq(1)
      expect(AuthorName.count).to eq(2)
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        author = FactoryGirl.create :author
        expect(author.versions.last.event).to eq('create')
      end
    end
  end

end
