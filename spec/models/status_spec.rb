# coding: UTF-8
require 'spec_helper'

describe Status do

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      Status['synonym'].to_s.should == 'synonym'
      Status['synonym'].to_s(:plural).should == 'synonyms'
    end
  end

  describe "Select box options" do
    it "should not include 'original combination'" do
      Status.options_for_select.map(&:first).include?('valid').should be_true
      Status.options_for_select.map(&:first).include?('original combination').should be_false
    end
  end

end
