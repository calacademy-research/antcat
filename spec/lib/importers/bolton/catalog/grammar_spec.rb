# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Grammar do
  before do
    @grammar = Importers::Bolton::Catalog::Grammar
  end

  describe "incertae sedis in" do
    it "should recognize incertae sedis" do
      @grammar.parse('<i>incertae sedis</i> in', :root => :incertae_sedis_in)
    end
  end

  describe "nomina nuda in" do
    it "should recognize it" do
      @grammar.parse('<i>nomina nuda</i> in', :root => :nomina_nuda_in)
    end
  end

  describe "nomina nuda" do
    it "should recognize it" do
      @grammar.parse('<i>nomina nuda</i>', :root => :nomina_nuda)
    end
  end

  describe "nomen nudum" do
    it "should recognize one" do
      @grammar.parse('<i>nomen nudum</i>', :root => :nomen_nudum)
    end
  end

  describe "Fossil flag" do
    it "should recognize *" do
      @grammar.parse('*', :root => :fossil_flag).should_not be_nil
    end
  end

  describe "Taxonomic history references" do

    describe 'subsequent authors' do
      it "should handle 'subsequent authors and <reference>'" do
        @grammar.parse(%{Emery, 1913a: 27; subsequent authors and Jaffe, 1993: 9}, :root => :taxonomic_history_references).value_with_reference_text_removed.should == {:references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '27'},
            {:subsequent_authors => 'subsequent authors and Jaffe, 1993: 9'}
          ]}
      end
      it "should handle 'all subsequent authors and <reference>'" do
        @grammar.parse(%{Emery, 1913a: 27; all subsequent authors and Jaffe, 1993: 9}, :root => :taxonomic_history_references).value_with_reference_text_removed.should == {:references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '27'},
            {:subsequent_authors => 'all subsequent authors and Jaffe, 1993: 9'}
          ]}
      end
      it "should handle 'all subsequent authors'" do
        @grammar.parse(%{Emery, 1913a: 27; all subsequent authors}, :root => :taxonomic_history_references).value_with_reference_text_removed.should == {
          :references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '27'},
            {:subsequent_authors => 'all subsequent authors'},
          ]}
      end
      it "should handle 'all subsequent authors to the following'" do
        @grammar.parse(%{Emery, 1913a: 27; all subsequent authors to the following}, :root => :taxonomic_history_references).value_with_reference_text_removed.should == {
          :references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '27'},
            {:subsequent_authors => 'all subsequent authors to the following'},
          ]}
      end
    end

    it "should handle bracketed notes" do
      @grammar.parse(%{André, 1881b: 64 [Formicidae]}, :root => :taxonomic_history_reference).value_with_reference_text_removed.should == {
        :author_names => ['André'], :year => '1881b', :pages => '64',
        :text => [
          {:opening_bracket => '['},
          {:family_or_subfamily_name => 'Formicidae'},
          {:closing_bracket => ']'},
        ]
      }
    end
  end

end
