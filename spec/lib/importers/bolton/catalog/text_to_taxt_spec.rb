# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::TextToTaxt do
  before do
    @converter = Importers::Bolton::Catalog::TextToTaxt
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
  it "should not strip leading and trailing blanks" do
    data = [{:phrase => ' Phrase '}]
    @converter.convert(data).should == ' Phrase '
  end
  it "should handle just a delimiter" do
    data = [{:delimiter => '.'}]
    @converter.convert(data).should == '.'
  end
  it "should handle a phrase inside a text" do
    data = [{:text => [{:phrase => 'Phrase'}]}]
    @converter.convert(data).should == 'Phrase'
  end

  it "should handle prefix and suffix" do
    data = [{:text=> [{:phrase=>"junior synonym of"}], text_prefix:" ", text_suffix:'.'}]
    @converter.convert(data).should == ' junior synonym of.'
  end

  describe "Citations" do
    it "should handle a citation" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244'}]
      @converter.convert(data).should == "{ref #{reference.id}}: 244"
    end
    it "should handle a citation whose reference wasn't found" do
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244', :matched_text => 'Latreill, 1809'}]
      @converter.convert(data).should == "{ref #{MissingReference.first.id}}: 244"
    end
    it "should handle a citation whose reference wasn't matched" do
      bolton_reference = FactoryGirl.create :bolton_reference, :authors => 'Latreille', :citation_year => '1809'
      data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244', :matched_text => 'Latreille, 1809'}]
      @converter.convert(data).should == "{ref #{MissingReference.first.id}}: 244"
    end
    it "should handle a nested citation" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Holldobler Wilson 1990'
      data = [{
        :author_names => ["Bolton"],
        :in => {:author_names => ["Holldobler", "Wilson"], :year => "1990"},
        :pages => "24"}]
      @converter.convert(data).should == "Bolton, in {ref #{reference.id}}: 24"
    end
    it "should handle a citation with notes" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Stephens 1829'
      data = [{
        author_names:["Stephens"], year:"1829", pages:"356",
        notes:[[
          {phrase:"first spelling as", delimiter:" "},
          {family_or_subfamily_name:"Formicidae"},
          {bracketed:true}
        ]],
      }]
      name = create_name 'Formicidae'
      @converter.convert(data).should == "{ref #{reference.id}}: 356 [first spelling as {nam #{name.id}}]"
    end

    it "should handle a citation with form" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Stephens 1829'
      data = [{author_names:["Stephens"], year:"1829", pages:"356", forms: 'q'}]
      @converter.convert(data).should == "{ref #{reference.id}}: 356 (q)"
    end

    it "should handle notes" do
      data = [
        [{:phrase=>"online"}, {:bracketed=>true}],
        [{:phrase=>"diagnosis"}]
      ]
      @converter.notes_item(data).should == " [online] (diagnosis)"
    end

  end

  it "should handle a number of items" do
    reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'
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
    name = create_name 'Formicariae'
    @converter.convert(data).should == "Formicidae as family: {ref #{reference.id}}: 124 [{nam #{name.id}}]; all subsequent authors"
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

  describe "Parenthesized items" do
    it "should handle a parenthesized text item" do
      data = [{:opening_parenthesis => '('}, {:phrase => 'foo'}, {:closing_parenthesis => ')'}]
      @converter.convert(data).should == "(foo)"
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
        Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
        @converter.convert([key => 'Formicariae']).should == '{nam 1234}'
      end
    end
    [:collective_group_name, :genus_name].each do |key|
      it "should handle #{key}" do
        Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
        @converter.convert([key => 'Calyptites']).should == '{nam 1234}'
      end
    end
    it "should handle family/order" do
      Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
      @converter.convert([
        {family_or_subfamily_name:"Myrmiciidae", suborder_name:"Symphyta", delimiter:": "}
      ]).should == '{nam 1234}: '
    end
    it "should not get confused by there being a current genus while a family-group name is seen" do
      current_genus = create_genus
      data = [{family_or_subfamily_name: 'Mutillidae', delimiter: ': '}]
      @converter.convert(data, current_genus.name.to_s).should == "{nam #{Name.find_by_name('Mutillidae').id}}: "
    end
    it "should handle fossil family/order" do
      Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
      @converter.convert([
        {:family_or_subfamily_name=>"Myrmiciidae", :fossil=>true, :suborder_name=>"Symphyta", :delimiter=>": "}
      ]).should == '{nam 1234}: '
    end
    it "should handle taxon names with other text" do
      Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
      Taxt.should_receive(:encode_taxon_name).and_return '{nam 5678}'
      @converter.convert([
        {family_or_subfamily_name:  'Formicariae', :delimiter => ' '},
        {phrase:  'or', :delimiter => ' '},
        {family_or_subfamily_name:  'Formicidae'},
      ]).should == "{nam 1234} or {nam 5678}"
    end

    describe "Converting species names" do
      it "should handle a species name" do
        data = {genus_name: 'Eoformica', species_epithet: 'eocenica'}
        Taxt.should_receive(:encode_taxon_name).with(data).and_return '{nam 1234}'
        @converter.convert([data]).should == '{nam 1234}'
      end
      it "should handle a species name when the genus is provided as an object" do
        genus_name = create_genus.name.to_s
        data = {genus_name: genus_name, species_epithet: 'eocenica'}
        Taxt.should_receive(:encode_taxon_name).with(data).and_return '{nam 1234}'
        @converter.convert([data], genus_name).should == '{nam 1234}'
      end
      it "should pass the genus_name back to a nested convert" do
        genus_name = create_genus.name.to_s
        data = [{genus_name: genus_name, species_epithet: 'eocenica'}, {genus_name: genus_name, species_epithet: 'major'}]
        Taxt.should_receive(:encode_taxon_name).with(data.first).and_return '{nam 1234}'
        Taxt.should_receive(:encode_taxon_name).with(data.second).and_return '{nam 5678}'
        @converter.convert(data, genus_name).should == '{nam 1234}{nam 5678}'
      end
      it "should handle a species name with subgenus" do
        data = {genus_name: 'Formica', subgenus_epithet: 'Hypochira', species_epithet: 'subspinosa'}
        Taxt.should_receive(:encode_taxon_name).and_return '{nam 1234}'
        @converter.convert([data]).should == '{nam 1234}'
      end
      it "should handle an abbreviated genus name + subgenus epithet" do
        Taxt.should_receive(:encode_taxon_name).
          with(genus_name: 'Atta', subgenus_epithet: 'Monacis').and_return '{nam 1234}'
        @converter.convert([{genus_abbreviation: 'D.', subgenus_epithet: 'Monacis'}], 'Atta').should == '{nam 1234}'
      end
      it "should handle an abbreviated genus name + species epithet" do
        Taxt.should_receive(:encode_taxon_name).
          with(genus_name: 'Atta', species_epithet: 'major').and_return '{nam 1234}'
        @converter.convert([{genus_abbreviation: 'A.', species_epithet: 'major'}], 'Atta').should == '{nam 1234}'
      end
    end

    describe "Converting subspecies names" do
      it "should handle subspecies epithet" do
        Taxt.should_receive(:encode_taxon_name).with(genus_name: 'Atta', species_epithet: 'major', subspecies: [{subspecies_epithet: 'rufa'}]).and_return '{nam 1234}'
        @converter.convert([{subspecies_epithet: 'rufa'}], 'Atta', 'major').should == '{nam 1234}'
      end
    end

  end

  describe "Taxon names with authorship" do
    it "should encode the authorship, too" do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Gray 1841'
      genus = create_genus 'Diabolus'
      @converter.convert([{
        genus_name: "Diabolus",
        authorship:
          [{author_names: ["Gray, J.E."],
            year: "1841",
            pages: "400",
            matched_text: "Gray, J.E. 1841: 400 (Mammalia)"}],
        delimiter: "."}]).should ==
          "{tax #{genus.id}} {ref #{reference.id}}: 400."
    end
  end

end
