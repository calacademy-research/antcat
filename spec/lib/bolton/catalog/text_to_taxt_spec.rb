# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::TextToTaxt do
  before do
    @converter = Bolton::Catalog::TextToTaxt
  end

  it "should handle an empty string" do
    @converter.convert({}).should == ''
  end
  it "should handle nil" do
    @converter.convert(nil).should == ''
  end
  it "should handle a phrase" do
    data = [{:phrase => 'Phrase'}]
    @converter.convert(data).should == 'Phrase'
  end
  it "should handle a phrase inside a text" do
    data = [{:text => [{:phrase => 'Phrase'}]}]
    @converter.convert(data).should == 'Phrase'
  end

  describe "Citations" do
    it "should handle a citation" do
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244'}]
      @converter.convert(data).should == "{ref #{reference.id}}: 244"
    end
    it "should handle a citation whose reference wasn't found" do
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244', :reference_text => 'Latreill, 1809'}]
      @converter.convert(data).should == "{ref #{MissingReference.first.id}}: 244"
    end
    it "should handle a citation whose reference wasn't matched" do
      bolton_reference = Factory :bolton_reference, :authors => 'Latreille', :citation_year => '1809'
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244', :reference_text => 'Latreille, 1809'}]
      @converter.convert(data).should == "{ref #{MissingReference.first.id}}: 244"
    end
    it "should handle a nested citation (i.e., without year)" do
      reference = Factory :article_reference, :bolton_key_cache => 'Nel Perrault 2004'
      data = [{
        :author_names => ["Nel", "Perrault"],
        :in => {:author_names => ["Nel", "Perrault", "Perrichot", "Néraudeau"], :year => "2004"},
        :pages => "24"}]
      @converter.convert(data).should == "{ref #{reference.id}}: 24"
    end
  end

  it "should handle a number of items" do
    reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
    data = [
      {:phrase => 'Formicidae as family', :delimiter => ': '},
      {:author_names => ['Latreille'], :year => '1809', :pages => '124', :delimiter => ' '},
      {:text => [
        {:opening_bracket => '['},
        {:family_or_subfamily_name => 'Formicariae'},
        {:closing_bracket => ']'},
      ], :delimiter => '; '},
      {:phrase => 'all subsequent authors'},
    ]
    @converter.convert(data).should == "Formicidae as family: {ref #{reference.id}}: 124 [Formicariae]; all subsequent authors"
  end

  describe "Bracketed items" do
    it "should handle a bracketed text item" do
      data = [{:opening_bracket => '['}, {:phrase => 'all rights reserved'}, {:closing_bracket => ']'}]
      @converter.convert(data).should == "[all rights reserved]"
    end
    it "should handle a bracketed text item nested in a text" do
      data = [:text => [{:opening_bracket => '['}, {:phrase => 'all rights reserved'}, {:closing_bracket => ']'}], :delimiter => ': ']
      @converter.convert(data).should == "[all rights reserved]: "
    end
  end

  describe "Unparseable items" do
    it "should handle it" do
      data = [{:unparseable=>"?: Swainson & Shuckard, 1840: 173"}]
      @converter.convert(data).should == "{? ?: Swainson & Shuckard, 1840: 173}"
    end
  end

  describe "Taxon names" do
    [:order_name, :family_or_subfamily_name, :tribe_name, :subtribe_name].each do |key|
      it "should handle #{key}" do
        @converter.convert([key => 'Formicariae']).should == "Formicariae"
      end
    end
    [:collective_group_name, :genus_name].each do |key|
      it "should handle #{key}" do
        @converter.convert([key => 'Calyptities']).should == "<i>Calyptities</i>"
      end
    end
    it "should handle family/order" do
      @converter.convert([
        {:family_name=>"Myrmiciidae", :fossil=>true, :suborder=>"Symphyta", :delimiter=>": "}
      ]).should == 'Myrmiciidae (Symphyta): '
    end
    it "should handle taxon names with other text" do
      @converter.convert([
        {:family_or_subfamily_name => 'Formicariae', :delimiter => ' '},
        {:phrase => 'or', :delimiter => ' '},
        {:family_or_subfamily_name => 'Formicidae'},
      ]).should == "Formicariae or Formicidae"
    end
  end

end
