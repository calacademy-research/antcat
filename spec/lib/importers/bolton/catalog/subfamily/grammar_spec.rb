# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Grammar do

  before do
    @grammar = Importers::Bolton::Catalog::Subfamily::Grammar
  end

  it "should parse a family_group_name followed by a question mark" do
    expect(@grammar.parse("<i>Condylodon</i> in Ponerinae?: Emery, 1921f: 28 (footnote).", :root => :texts).value_with_matched_text_removed).to eq({
      :type => :texts,
      :texts => [{
          :text => [
            {:genus_name => "Condylodon", :delimiter => " "},
            {:phrase => "in", :delimiter => " "},
            {:family_or_subfamily_name => "Ponerinae", :questionable => true, :delimiter => ": "},
            {:author_names => ["Emery"], :year => "1921f", :pages => "28 (footnote)"},
      ], text_suffix:'.'}]
    })
  end

  it "should parse 'Combination in..." do
    expect(@grammar.parse("Combination in", root: :texts).value_with_matched_text_removed).to eq({
      type: :texts, texts: [{text:[ {phrase: "Combination in"}]}]
    })
  end

  it "should recognize the usual supersubfamily header" do
    expect(@grammar.parse(%{THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE}).value_with_matched_text_removed).to eq({:type => :supersubfamily_header})
  end

  it "should recognize the supersubfamily header when there's only one subfamily" do
    expect(@grammar.parse(%{THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE}).value_with_matched_text_removed).to eq({:type => :supersubfamily_header})
  end

  it "should recognize the supersubfamily header for extinct subfamilies" do
    expect(@grammar.parse(%{EXTINCT SUBFAMILIES OF FORMICIDAE: *ARMANIINAE, *BROWNIMECIINAE, *FORMICIINAE, *SPHECOMYRMINAE}).value_with_matched_text_removed).to eq(
      {:type => :supersubfamily_header}
    )
  end

  it "should handle regional and national faunas with keys" do
    expect(@grammar.parse('Regional and national faunas with keys').value_with_matched_text_removed).to eq({
      :type => :regional_and_national_faunas_header
    })
  end
  describe "Collective group name header" do
    it "should be recognized" do
      expect(@grammar.parse(%{*<i>MYRMICITES</i>}).value_with_matched_text_removed).to eq({
        :type => :collective_group_name_header,
        :collective_group_name => 'Myrmicites',
        :fossil => true
      })
    end
  end

  describe "References header" do
    it "should handle references for a single tribe" do
      expect(@grammar.parse('Tribe Aneuretini references').value_with_matched_text_removed).to eq({
        type: :references_section_header,
        title: 'Tribe Aneuretini references'
      })
    end
    it "should handle references for a tribe and genus" do
      expect(@grammar.parse('Tribe Cheliomyrmecini and genus <i>Cheliomyrmex</i> references').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Tribe Cheliomyrmecini and genus <i>Cheliomyrmex</i> references'
      })
    end
    it "should handle references for subfamily and tribes (no names)" do
      expect(@grammar.parse('Subfamily and tribes references').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Subfamily and tribes references'
      })
    end
  end

  describe "Texts" do
    it "should handle return anything it doesn't understand as texts" do
      expect(@grammar.parse('Moo-goo-gai-pan').value_with_matched_text_removed).to eq({
        :type => :texts,
        :texts => [:text => [{:phrase => 'Moo-goo-gai-pan'}]]
      })
    end
  end

end
