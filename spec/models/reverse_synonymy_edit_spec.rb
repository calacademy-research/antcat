# coding: UTF-8
require 'spec_helper'

describe ReverseSynonymyEdit do

  describe "The object" do

    it "should require both the junior and senior" do
      history = ReverseSynonymyEdit.new
      history.should_not be_valid
      history.user = User.new
      new_junior = create_species 'Formica major'
      history.new_junior = new_junior
      history.should_not be_valid
      new_senior = create_species 'Formica minor'
      history.new_senior = new_senior
      history.should be_valid
      history.save!
      history.reload
      history.new_junior.should == new_junior
      history.new_senior.should == new_senior
    end

    it "should be creatable" do
      user = User.new
      new_junior = create_species 'Formica major'
      new_senior = create_species 'Formica minor'
      history = ReverseSynonymyEdit.create! user: user, new_junior: new_junior, new_senior: new_senior
      history = ReverseSynonymyEdit.first
      history.new_junior.should == new_junior
      history.new_senior.should == new_senior
    end

  end
end
