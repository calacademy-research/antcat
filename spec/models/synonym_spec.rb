# coding: UTF-8
require 'spec_helper'

describe Synonym do

  describe "The object" do

    it "should require the junior, but not the senior" do
      synonym = Synonym.new
      synonym.should_not be_valid
      synonym.junior_synonym = create_species 'Formica'
      synonym.should be_valid
      synonym.senior_synonym = create_species 'Atta'
      synonym.save!
      synonym.reload
      synonym.junior_synonym.name.to_s.should == 'Formica'
      synonym.senior_synonym.name.to_s.should == 'Atta'
    end

  end
end
