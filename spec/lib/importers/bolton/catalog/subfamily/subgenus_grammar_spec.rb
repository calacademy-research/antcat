# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::SubgenusGrammar do
  before do
    @grammar = Importers::Bolton::Catalog::Subfamily::Grammar
  end

  describe "Subgenus grammar" do

    describe "Subgenera header" do
      it "should be recognized" do
        expect(@grammar.parse(%{Subgenera of <i>MYRMOTERAS</i> include the nominal plus the following.}, root: :subgenera_header).value).to eq({type: :subgenera_header, name: 'Myrmoteras'})
      end
    end

    describe "Subgenus header" do
      it "should be recognized" do
        expect(@grammar.parse(%{Subgenus <i>STIGMACROS (MYAGROTERAS)</i>}).value).to eq({:type => :subgenus_header, :name => 'Myagroteras'})
      end
    end

    describe "Junior synonyms of subgenus header" do
      it "should be recognized" do
        expect(@grammar.parse(%{Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i>}).value).to eq({:type => :junior_synonyms_of_subgenus_header})
      end
      it "should be recognized when there's only one" do
        expect(@grammar.parse(%{Junior synonym of <i>CAMPONOTUS (MAYRIA)</i>}).value).to eq({:type => :junior_synonyms_of_subgenus_header})
      end
    end

  end
end
