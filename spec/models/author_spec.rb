# coding: UTF-8
require 'spec_helper'

describe Author do
  it "has many names" do
    author = Author.create!
    author.names << Factory(:author_name)
    author.should have(1).name
  end

  describe "sorting by first author name" do
    it "should work" do
      ward = Factory :author_name, :name => 'Ward'
      fisher_b_l = Factory :author_name, :name => 'Fisher, B. L.'
      fisher = Factory :author_name, :name => 'Fisher', :author => fisher_b_l.author 
      bolton = Factory :author_name, :name => 'Bolton'
      Author.sorted_by_name.should == [bolton.author, fisher.author, ward.author]
    end
  end
end
