# coding: UTF-8
require 'spec_helper'

describe Citation do
  it "has a Reference" do
    reference = Factory :reference
    reference_location = Citation.create! :reference => reference
    reference_location.reload.reference.should == reference
  end

  describe "Importing" do
    it "should create the Citation, which is linked to an existing Reference" do
      data = {:author_names => ["Latreille"], :year => "1809", :pages => "124"}

      citation = Citation.import(data).reload

      citation.pages.should == '124'
      
      reference = citation.reference
      reference.year.should == 1809
      reference.author_names_string.should == 'Latreille'
    end
  end

end
