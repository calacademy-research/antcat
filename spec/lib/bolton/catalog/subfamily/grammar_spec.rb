# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Grammar do

  before do
    @grammar = Bolton::Catalog::Subfamily::Grammar
  end

  it "should parse a family_group_name followed by a question mark" do
    @grammar.parse("<i>Condylodon</i> in Ponerinae?: Emery, 1921f: 28 (footnote).", root: :texts).value_with_reference_text_removed.should == {
      type: :texts,
      texts: [{
          text: [
            {genus_name: "Condylodon", delimiter: " "},
            {phrase: "in", delimiter: " "},
            {family_or_subfamily_name: "Ponerinae", questionable: true, delimiter: ": "},
            {author_names: ["Emery"], year: "1921f", pages: "28 (footnote)"},
      ]}]
    }
 end

  it "should recognize the usual supersubfamily header" do
    @grammar.parse(%{THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE}).value_with_reference_text_removed.should == {type: :supersubfamily_header}
  end

  it "should recognize the supersubfamily header when there's only one subfamily" do
    @grammar.parse(%{THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE}).value_with_reference_text_removed.should == {type: :supersubfamily_header}
  end

  it "should recognize the supersubfamily header for extinct subfamilies" do
    @grammar.parse(%{EXTINCT SUBFAMILIES OF FORMICIDAE: *ARMANIINAE, *BROWNIMECIINAE, *FORMICIINAE, *SPHECOMYRMINAE}).value_with_reference_text_removed.should ==
      {type: :supersubfamily_header}
  end

  it "should handle regional and national faunas with keys" do
    @grammar.parse('Regional and national faunas with keys').value_with_reference_text_removed.should == {
      type: :regional_and_national_faunas_header
    }
  end
  describe "Collective group name header" do
    it "should be recognized" do
      @grammar.parse(%{*<i>MYRMICITES</i>}).value_with_reference_text_removed.should == {
        type: :collective_group_name_header,
        collective_group_name: 'Myrmicites',
        fossil: true
      }
    end
  end

  describe "References header" do
    it "should handle references for a single tribe" do
      @grammar.parse('Tribe Aneuretini references').value_with_reference_text_removed.should == {
        type: :references_section_header,
        taxa: {tribe_name: 'Aneuretini'}
      }
    end
    it "should handle references for a tribe and genus" do
      @grammar.parse('Tribe Cheliomyrmecini and genus <i>Cheliomyrmex</i> references').value_with_reference_text_removed.should == {
        type: :references_section_header,
        taxa: {tribe: {tribe_name: 'Cheliomyrmecini'}, genus: {genus_name: 'Cheliomyrmex'}}
      }
    end
    it "should handle references for subfamily and tribes (no names" do
      @grammar.parse('Subfamily and tribes references').value_with_reference_text_removed.should == {
        type: :references_section_header,
        taxa: {tribes: true, subfamily: true}
      }
    end
  end

  describe "Texts" do
    it "should handle return anything it doesn't understand as texts" do
      @grammar.parse('Moo-goo-gai-pan').value_with_reference_text_removed.should == {
        type: :texts,
        texts: [text: [{phrase: 'Moo-goo-gai-pan'}]]
      }
    end
  end

end
