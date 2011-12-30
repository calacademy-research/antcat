# coding: UTF-8
require 'spec_helper'

describe Citation do

  it "has a Reference" do
    reference = Factory :reference
    citation = Citation.create! :reference => reference
    citation.reload.reference.should == reference
  end

  describe "Importing" do
    it "should create the Citation, which is linked to an existing Reference" do
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809a'
      data = {:author_names => ["Latreille"], :year => "1809a", :pages => "124"}

      citation = Citation.import(data).reload

      citation.pages.should == '124'
      citation.reference.should == reference
    end
    it "should handle a nested reference when the year is only with the parent" do
      reference = Factory :nested_reference, :bolton_key_cache => 'Latreille 2004'
      data = {
        :author_names => ["Latreille"],
        :in => {
          :author_names => ["Bolton"], :year => "2004"
        },
        :pages=>"24"
      }

      citation = Citation.import(data).reload

      citation.pages.should == '24'
      citation.reference.should == reference
    end
  end

end
