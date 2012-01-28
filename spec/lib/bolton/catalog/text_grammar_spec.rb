# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Grammar do
  before do
    @grammar = Bolton::Catalog::Grammar
  end

  it "should parse a family/subfamily name" do
    @grammar.parse("Formicinae", :root => :text).value_with_reference_text_removed.should == {:text => [:family_or_subfamily_name => 'Formicinae']}
  end

  it "should parse a family/subfamily name followed by a ?" do
    @grammar.parse("Formicinae?", :root => :text).value_with_reference_text_removed.should == {:text => [:family_or_subfamily_name => 'Formicinae', :questionable => true]}
  end

  it "should parse words followed by family/subfamily name" do
      @grammar.parse(%{not in Pseudomyrmecinae}, :root => :text).value_with_reference_text_removed.should == {
        :text => [
          {:phrase => "not in", :delimiter => ' '},
          {:family_or_subfamily_name => 'Pseudomyrmecinae'},
        ]
      }
  end

  it "should parse words followed by family/subfamily name followed by more words" do
      @grammar.parse(%{not in Pseudomyrmecinae, dubiously in Myrmecenae}, :root => :text).value_with_reference_text_removed.should == {
        :text => [
          {:phrase => "not in", :delimiter => ' '},
          {:family_or_subfamily_name => 'Pseudomyrmecinae'},
          {:phrase => ", dubiously in", :delimiter => ' '},
          {:family_or_subfamily_name => 'Myrmecenae'},
        ]
      }
  end

  it "should parse words followed by family/subfamily name" do
      @grammar.parse(%{not in Pseudomyrmecinae}, :root => :text).value_with_reference_text_removed.should == {
        :text => [
          {:phrase => "not in", :delimiter => ' '},
          {:family_or_subfamily_name => 'Pseudomyrmecinae'},
        ]
      }
  end

  it "should parse a tribe name" do
    @grammar.parse("Formicini", :root => :text).value_with_reference_text_removed.should == {:text => [:tribe_name => 'Formicini']}
  end

  it "should parse a single word" do
    @grammar.parse("Mayr", :root => :text).value_with_reference_text_removed.should == {:text => [{:phrase => 'Mayr'}]}
  end

  it "should parse this instead of just giving it up as unparseable" do
    @grammar.parse("[According to Emery, 1892b: 162, this is a termite, Order ISOPTERA]", :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_bracket => '['},
        {:phrase => 'According to', :delimiter => ' '},
        {:author_names => ['Emery'], :year => '1892b', :pages => '162'},
        {:phrase => ', this is a termite, Order ISOPTERA'},
        {:closing_bracket => ']'},
      ]
    }
  end

  it "should parse lots of italicized stuff" do
    @grammar.parse("[Later references to this name, <i>e.g</i>. Emery, 1884a: 381; Emery, 1891b: 8, are <i>nomina nuda</i> or unavailable names.]", :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_bracket => '['},
        {:phrase => 'Later references to this name, <i>e.g</i>.', :delimiter => ' '},
        {:author_names => ['Emery'], :year => '1884a', :pages => '381', :delimiter => '; '},
        {:author_names => ['Emery'], :year => '1891b', :pages => '8'},
        {:phrase => ', are', :delimiter => ' '},
        {:phrase => '<i>nomina nuda</i>', :delimiter => ' '},
        {:phrase => 'or unavailable names', :delimiter => '.'},
        {:closing_bracket => ']'},
      ]
    }
  end

  it "should parse a parenthesized phrase" do
    @grammar.parse(%{(family unresolved)}, :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_parenthesis => '('},
        {:phrase => 'family unresolved'},
        {:closing_parenthesis => ')'}
      ]
    }
  end

  it "should parse a parenthesized phrase not ending with a period" do
    @grammar.parse(%{(as *<i>Myrmecium</i>, incorrect subsequent spelling)}, :root => :parenthesized_text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_parenthesis => '('},
        {:phrase => "as", :delimiter => ' '},
        {:genus_name => 'Myrmecium', :fossil => true},
        {:phrase => ', incorrect subsequent spelling'},
        {:closing_parenthesis => ')'},
      ]
    }
  end
  it "should parse a parenthesized phrase ending with a period" do
    @grammar.parse(%{(family unresolved).}, :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_parenthesis => '('},
        {:phrase => 'family unresolved'},
        {:closing_parenthesis => ')'},
        {:delimiter => '.'}
      ]
    }
  end

  it "should handle a quoted phrase" do
    @grammar.parse(%{Included as "(Myrmicinae) <i>longaeva</i>": Carpenter, 1930: 21}, :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => 'Included as', :delimiter => ' '},
        {:phrase => '"(Myrmicinae) <i>longaeva</i>"', :delimiter => ': '},
        {:author_names => ['Carpenter'], :year => '1930', :pages => '21'},
      ]
    }
  end

  it "should handle an abbreviated genus" do
    @grammar.parse(%{<i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90, unnecessary replacement name.}, :root => :text)
  end

  it "should parse a set of words" do
    @grammar.parse("Mayr considers <i>afar</i> Mayr, 1923 to be a termite: Mayr, 1962: 23", :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => 'Mayr considers', :delimiter => ' '},
        {:species_group_epithet => 'afar', :authorship => [{:author_names => ['Mayr'], :year => '1923'}], :delimiter => ' '},
        {:phrase => 'to be a termite', :delimiter => ': '},
        {:author_names => ['Mayr'], :year => '1962', :pages => '23'},
      ]
    }
  end

  it "should handle a period after a bracket" do
    @grammar.parse(%{[<i>Formica truncorum</i> ab. <i>stitzi</i> Stitz, 1939: 347; unavailable name.].}, :root => :text)
  end

  it "should parse a bracketed string" do
    @grammar.parse("[A note]", :root => :text).value_with_reference_text_removed.should == {
      :text => [{:opening_bracket => '['}, {:phrase => 'A note'}, {:closing_bracket => ']'}]
    }
  end

  it "bracketed_text rule should leave the ending period" do
    @grammar.parse("[A note].", :root => :bracketed_text, :consume => false).value_with_reference_text_removed.should == {
      :text => [{:opening_bracket => '['}, {:phrase => 'A note'}, {:closing_bracket => ']'}]
    }
  end

  it "should parse text with an apostrophe" do
    @grammar.parse("Smith's hubris", :root => :text).value_with_reference_text_removed.should == {
      :text => [{:phrase => "Smith's hubris"}]
    }
  end
  it "should parse it even when there's bracketed text inside" do
    @grammar.parse("Hence <i>candida</i> first available replacement name for <i>Formica picea</i> Nylander, 1846a: 917 [Junior primary homonym of <i>Formica picea</i> Leach, 1825: 292 (now in <i>Camponotus</i>).]: Bolton, 1995b: 192.",
                    :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => "Hence", :delimiter => ' '},
        {:species_group_epithet => "candida", :delimiter => ' '},
        {:phrase => "first available replacement name for", :delimiter => ' '},
        {:genus_name => "Formica", :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander'], :year => '1846a', :pages => '917'}], :delimiter => ' '},
        {:text => [
          {:opening_bracket => '['},
          {:phrase => "Junior primary homonym of", :delimiter => ' '},
          {:genus_name => "Formica", :species_epithet => 'picea',
           :authorship => [{:author_names => ['Leach'], :year => '1825', :pages => '292',
           :notes => [[
              {:phrase => "now in", :delimiter => ' '},
              {:genus_name => 'Camponotus'},
            ]]}],
            :delimiter => '.',
          },
          {:closing_bracket => ']'},
        ], :delimiter => ": "},
        {:author_names => ['Bolton'], :year => '1995b', :pages => '192'}
      ],
      text_suffix: '.'
    }
  end

  it "should parse a bracketed string" do
    @grammar.parse("[A note]", :root => :text).value_with_reference_text_removed.should == {
      :text => [{:opening_bracket => '['}, {:phrase => 'A note'}, {:closing_bracket => ']'}]
    }
  end

  it "should parse text with an apostrophe" do
    @grammar.parse("Smith's hubris", :root => :text).value_with_reference_text_removed.should == {
      :text => [{:phrase => "Smith's hubris"}]
    }
  end
  it "should parse it even when there's bracketed text inside" do
    @grammar.parse("Hence <i>candida</i> first available replacement name for <i>Formica picea</i> Nylander, 1846a: 917 [Junior primary homonym of <i>Formica picea</i> Leach, 1825: 292 (now in <i>Camponotus</i>).]: Bolton, 1995b: 192.",
                    :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => "Hence", :delimiter => ' '},
        {:species_group_epithet => "candida", :delimiter => ' '},
        {:phrase => "first available replacement name for", :delimiter => ' '},
        {:genus_name => "Formica", :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander'], :year => '1846a', :pages => '917'}], :delimiter => ' '},
        {:text => [
          {:opening_bracket => '['},
          {:phrase => "Junior primary homonym of", :delimiter => ' '},
          {:genus_name => "Formica", :species_epithet => 'picea',
           :authorship => [{:author_names => ['Leach'], :year => '1825', :pages => '292',
           :notes => [[
              {:phrase => "now in", :delimiter => ' '},
              {:genus_name => 'Camponotus'},
            ]]}],
            :delimiter => '.',
          },
          {:closing_bracket => ']'},
        ], :delimiter => ": "},
        {:author_names => ['Bolton'], :year => '1995b', :pages => '192'}
      ], text_suffix: '.'
    }
  end

  it "should include delimiters with following phrase" do
    @grammar.parse('[According to Emery, 1892b: 162, this is a termite, Order ISOPTERA]', :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_bracket => '['},
        {:phrase => 'According to', :delimiter => ' '},
        {:author_names => ['Emery'], :year => '1892b', :pages => '162'},
        {:phrase => ', this is a termite, Order ISOPTERA'},
        {:closing_bracket => ']'},
      ]
    }
  end

  it "should parse text with comma, name, and reference" do
    @grammar.parse("Valid species, not synonymous with <i>picea</i> Nylander: Seifert, 2004: 35.", :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => "Valid species, not synonymous with", :delimiter => ' '},
        {:species_group_epithet => "picea", :authorship => [{:author_names => ['Nylander']}], :delimiter => ': '},
        {:author_names => ['Seifert'], :year => '2004', :pages => '35'},
      ], text_suffix: '.'
    }
  end

  it "should parse text followed by reference without a delimiter" do
    @grammar.parse("Smith's description is repeated by Bingham, 1903: 335 (footnote).", :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => "Smith's description is repeated by", :delimiter => ' '},
        {:author_names => ['Bingham'], :year => '1903', :pages => '335 (footnote)'},
      ], text_suffix: '.'
    }
  end

  it "should handle text starting with a reference" do
    @grammar.parse('[Santschi, 1916e: 393 erroneously refers to this taxon as <i>major</i>.]',
                  :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:opening_bracket => '['},
        {:author_names => ['Santschi'], :year => '1916e', :pages => '393', :delimiter => ' '},
        {:phrase => 'erroneously refers to this taxon as', :delimiter => ' '},
        {:species_group_epithet => 'major', :delimiter => '.'},
        {:closing_bracket => ']'},
      ]
    }
  end

  it "should handle a semicolon" do
    @grammar.parse('[All these authors give <i>subnuda</i> as the senior name but the date of availability of <i>subnuda</i> makes it clear that <i>aserva</i> has seniority: Bolton, 1995b: 191; see also under <i>subnuda</i>.]', :root => :text)
  end

  it "should handle this semicolon" do
    @grammar.parse('[Kupyanskaya, 1990: 149 uses the name <i>orientalis</i>, apparently unaware of the revision by Francoeur, <i>et al</i>.; their synonymy is reaffirmed by Radchenko, 1994b: 111.]', :root => :text)
  end

  it "should handle a period inside brackets" do
    @grammar.parse("[Name may be based on a misinterpretation. Burmeister, 1831: 1100, does not name a species but mentions that he has a number of ants' heads (<i>formicae cephalicae</i>) in amber.]", :root => :text)
  end

  it "should handle this period inside brackets" do
    @grammar.parse("[Spelled <i>miniocca</i> p. 49, <i>minocca</i> p. 52.]", :root => :text)
  end

  it "should handle a Latin phrase that's not a genus name" do
    @grammar.parse('<i>formicae cephalicae</i>', :root => :text).value_with_reference_text_removed.should == {:text => [{:phrase => '<i>formicae cephalicae</i>'}]}
  end

  it "should handle this one" do
    @grammar.parse('[Creighton, Wilson & Brown, and Buren incorrectly make <i>subnuda</i> the senior name but <i>aserva</i> has priority and is therefore the valid name of this taxon: Bolton, 1995b: 204.]', :root => :text)
  end

  it "should handle this one" do
    @grammar.parse('[First available use of <i>Formica pallidefulva</i> subsp. <i>schaufussi</i> var. <i>dolosa</i> Wheeler, W.M. 1912c: 90; unavailable name and unnecessary replacement name for <i>meridionalis</i>]', :root => :text)
  end

  it "should handle this one, too" do
    @grammar.parse("(replacement name for *<i>parvula</i> Dlussky, proposed subsequent to Dlussky's 2002a synonymy and hence automatic junior synonym).", :root => :text).value_with_reference_text_removed.should ==
      {:text => [
        {:opening_parenthesis => '('},
        {:phrase => 'replacement name for', :delimiter => ' '},
        {:species_group_epithet => 'parvula', :fossil => true, :authorship => [{:author_names => ['Dlussky']}]},
        {:phrase => ", proposed subsequent to Dlussky's 2002a synonymy and hence automatic junior synonym"},
        {:closing_parenthesis => ')'},
        {:delimiter => '.'},
      ]}
  end

  it "should handle a species_epithet group" do
    @grammar.parse('Type-series referred to <i>testaceipes</i>-group (<i>recte</i> <i>terebrans</i>-group): McArthur & Adams, 1996: 41.', :root => :text).value
  end

  it "should not consider <i>recte</i> a species epithet" do
    @grammar.parse('<i>recte</i>', :root => :text).value_with_reference_text_removed.should == {:text => [{:phrase => '<i>recte</i>'}]}
  end

  it "should handle a plus sign" do
    @grammar.parse('Colombia + Panama', :root => :text).value_with_reference_text_removed.should == {
      :text => [
        {:phrase => 'Colombia', :delimiter => ' + '},
        {:phrase => 'Panama'}
      ]
    }
  end

  it "should save the leading whitespace/delimiters" do
    @grammar.parse(" Start here", :root => :text).value_with_reference_text_removed.should == {
      text: [{phrase: 'Start here'}], text_prefix: ' ' 
    }
  end

  it "should handle an asterisk" do
    @grammar.parse("*fossil taxa catalogue", :root => :text).value_with_reference_text_removed.should == {
      text: [{phrase: '*'}, {phrase: 'fossil taxa catalogue'}]
    }
  end

end
