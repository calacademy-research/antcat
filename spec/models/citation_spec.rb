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

    it "should link to a MissingReference, if necessary" do
      data = {:author_names => ["Latreille"], :year => "1809a", :pages => "124", :reference_text => 'Latreille, 1809a: 124'}
      citation = Citation.import(data).reload
      citation.pages.should == '124'
      missing_reference = citation.reference
      missing_reference.citation.should == 'Latreille, 1809a'
      missing_reference.reason_missing.should == 'no Bolton'
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

    it "should handle a note" do
      data = {
        :author_names=>["Scudder"],
        :year=>"1877b",
        :pages=>"270",
        :notes=>
        [
          [
            {:phrase=>"as member of family", :delimiter=>" "},
            {:family_or_subfamily_name=>"Braconidae"},
            {:bracketed=>true}
          ]
        ],
        :reference_text=> "Scudder, 1877b: 270 [as member of family Braconidae]"
      }

      citation = Citation.import(data).reload
      citation.notes_taxt.should == " [as member of family Braconidae]"
    end

  end
end
