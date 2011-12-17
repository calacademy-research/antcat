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
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      data = {:author_names => ["Latreille"], :year => "1809", :pages => "124"}

      citation = Citation.import(data).reload

      citation.pages.should == '124'
      citation.reference.should == reference
    end
  end

end
