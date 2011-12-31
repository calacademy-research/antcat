# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Grammar do
  before do
    @grammar = Bolton::Catalog::Grammar
  end

  describe "Taxon authorship" do
    it "can be just a single author name" do
      @grammar.parse('Cuezzo', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Cuezzo']
      }]
    end
    it "can be a single author name followed by 'above'" do
      @grammar.parse('Cuezzo, above', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Cuezzo']
      }]
    end
    it "can be an author name with year, page, and 'above" do
      @grammar.parse('Smith, F. 1858b: 13, above', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Smith, F.'], :year => '1858b', :pages => '13'
      }]
    end
    it "can be a single author name plus year" do
      @grammar.parse('Cuezzo, 1922', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Cuezzo'], :year => '1922'
      }]
    end
    it "can be a single author name plus year plus pages" do
      @grammar.parse('Cuezzo, 1922: 1', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Cuezzo'], :year => '1922', :pages => '1'
      }]
    end
    it "can be a single author name without year or pages but with 'above'" do
      @grammar.parse('Forel (above)', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Forel']
      }]
    end
    it "can be nested" do
      @grammar.parse('Gmelin, in Linnaeus, 1790: 2804 (w.)', :root => :authorship).value_with_reference_text_removed.should == [{
        :author_names => ['Gmelin'],
        :pages => '2804',
        :in => {:author_names => ['Linnaeus'], :year => '1790'},
        :forms => 'w.',
      }]
    end
  end

  describe "References" do
    it "can handle multiple references for a single author" do
      @grammar.parse('Emery, 1908a: 165, 1908c: 305, 1908: 437', :root => :references).value_with_reference_text_removed.should ==
        {:references => [
          {:author_names => ['Emery'],
           :publications => [
             {:year => '1908a', :pages => '165'},
             {:year => '1908c', :pages => '305'},
             {:year => '1908', :pages => '437'},
          ]}
        ]}
    end

    it "can handle a colon after the author" do
      @grammar.parse('Gonçalves: 1961: 153', :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Gonçalves'], :year => '1961', :pages => '153'}
      ]}
    end
    it "can have forms" do
      @grammar.parse('Cuezzo, 1922: 32 (w.q.m.)', :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Cuezzo'], :year => '1922', :pages => '32', :forms => 'w.q.m.'}
      ]}
    end
    it "can be a single author name plus year plus pages" do
      @grammar.parse('Cuezzo, 1922: 1', :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Cuezzo'], :year => '1922', :pages => '1'}
      ]}
    end
    it "can (no doubt accidentally) have a semicolon instead of a colon before the pages" do
      @grammar.parse('Cuezzo, 1922; 1', :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Cuezzo'], :year => '1922', :pages => '1'}
      ]}
    end
    it "should parse multiple references" do
      @grammar.parse('Cuezzo, 1900: 36; Bolton, 2000: 23', :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Cuezzo'], :year => '1900', :pages => '36'},
        {:author_names => ['Bolton'], :year => '2000', :pages => '23'},
      ]}
    end
    it "should parse multiple references with forms" do
      @grammar.parse('Wheeler, G.C. & Wheeler, J. 1966: 730 (l.); Cuezzo, 2000: 231 (q.m.)',
                      :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Wheeler, G.C.', 'Wheeler, J.'], :year => '1966', :pages => '730', :forms => 'l.'},
        {:author_names => ['Cuezzo'], :year => '2000', :pages => '231', :forms => 'q.m.'},
      ]}
    end
    it "should parse multiple references with forms, separated by semicolons" do
      @grammar.parse('Wheeler, G.C. & Wheeler, J. 1966: 730 (l.); Cuezzo, 2000: 231 (q.m.)',
                      :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Wheeler, G.C.', 'Wheeler, J.'], :year => '1966', :pages => '730', :forms => 'l.'},
        {:author_names => ['Cuezzo'], :year => '2000', :pages => '231', :forms => 'q.m.'},
      ]}
    end
    it "should parse a nested reference" do
      @grammar.parse('Wheeler, G.C., in Wheeler, G.C. & Wheeler, J. 1966: 730 (l.); Cuezzo, 2000: 231 (q.m.)',
                      :root => :references).value_with_reference_text_removed.should == {:references => [
        {:author_names => ['Wheeler, G.C.'], :in => {:author_names => ['Wheeler, G.C.', 'Wheeler, J.'], :year => '1966'}, :pages => '730', :forms => 'l.'},
        {:author_names => ['Cuezzo'], :year => '2000', :pages => '231', :forms => 'q.m.'},
      ]}
    end
    it "should parse this reference with complicated forms" do
      @grammar.parse('Eguchi, 2008: 238 (s.w.ergatoid q.)', :root => :reference).value_with_reference_text_removed.should == 
        {:author_names => ['Eguchi'], :year => '2008', :pages => '238', :forms => 's.w.ergatoid q.'}
    end
  end

  describe "Author names" do
    it "should handle 'do'" do
      @grammar.parse('Fernández, Delabie & do Nascimento', :root => :ref_author_names).value_with_reference_text_removed.should == ['Fernández', 'Delabie', 'do Nascimento'] 
    end
    it "should handle this name" do
      name = 'Lepeletier de Saint-Fargeau'
      @grammar.parse(name, :root => :ref_author_names).value_with_reference_text_removed.should == [name]
    end
    it "should parse Rossi de Garcia" do
      @grammar.parse('Rossi de Garcia', :root => :ref_author_names).value_with_reference_text_removed.should == ['Rossi de Garcia']
    end
    it "should parse an author name starting with 'de'" do
      @grammar.parse('de Romand', :root => :ref_author_names).value_with_reference_text_removed.should == ['de Romand']
    end
    it "should parse an author name without a space after the last name" do
      @grammar.parse('Smith,F.', :root => :ref_author_names).value_with_reference_text_removed.should == ['Smith,F.']
    end
    it "should parse an author name with an umlaut" do
      @grammar.parse('Özdikmen', :root => :ref_author_names).value_with_reference_text_removed.should == ['Özdikmen']
    end
    it "should parse a single author name" do
      @grammar.parse('Cuezzo', :root => :ref_author_names).value_with_reference_text_removed.should == ['Cuezzo']
    end
    it "should parse two author names" do
      @grammar.parse('Bolton & Fisher', :root => :ref_author_names).value_with_reference_text_removed.should == ['Bolton', 'Fisher']
    end
    it "should parse an author name with an initial" do
      @grammar.parse('Smith, F.', :root => :ref_author_names).value_with_reference_text_removed.should == ['Smith, F.']
    end
    it "should parse two author names with initials, including one with two" do
      @grammar.parse('Wheeler, G.C. & Wheeler, J.', :root => :ref_author_names).value_with_reference_text_removed.should == ['Wheeler, G.C.', 'Wheeler, J.']
    end
    it "should parse author names with particles" do
      @grammar.parse('De Groot & Le Torquet', :root => :ref_author_names).value_with_reference_text_removed.should == ['De Groot', 'Le Torquet']
    end
    it "should parse three authors with et al." do
      @grammar.parse('Imai, Baroni Urbani, Kubota, <i>et al.</i>', :root => :ref_author_names).value_with_reference_text_removed.should == ['Imai', 'Baroni Urbani', 'Kubota', '<i>et al.</i>']
    end
    it "should parse three authors" do
      @grammar.parse(%{Trager, MacGown & Trager}, :root => :ref_author_names).value_with_reference_text_removed.should == ['Trager', 'MacGown', 'Trager']
    end
    it "should parse an author with two last names" do
      @grammar.parse('Dalla Torre', :root => :ref_author_names).value_with_reference_text_removed.should == ['Dalla Torre']
    end
    it "should parse an author list with et al." do
      @grammar.parse('Dalla Torre, <i>et al.</i>', :root => :ref_author_names).value_with_reference_text_removed.should == ['Dalla Torre', '<i>et al.</i>']
    end
    it "should parse an author name with a hyphen" do
      @grammar.parse('Engel-Siegel', :root => :ref_author_name)
    end
  end

  describe "Forms" do

    it "should not consider just any old text as forms" do
      lambda {@grammar.parse('(family unresolved)', :root => :ref_forms)}.should raise_error Citrus::ParseError
    end
    it "should parse forms" do
      @grammar.parse('(w.q.)', :root => :ref_forms).value_with_reference_text_removed.should == 'w.q.'
    end
    it "should handle quoted phrases" do
      @grammar.parse(%{(s.q. "dwarf q." m.)}, :root => :ref_forms).value_with_reference_text_removed.should == 's.q. "dwarf q." m.'
    end
    it "should parse one form it doesn't know about, as long as it's an initial" do
      @grammar.parse('(l.)', :root => :ref_forms).value_with_reference_text_removed.should == 'l.'
    end
    it "should parse forms it doesn't know about, as long as they're initials" do
      @grammar.parse('(a.b.)', :root => :ref_forms).value_with_reference_text_removed.should == 'a.b.'
    end
    it "should parse initials followed by ?" do
      @grammar.parse('(a.b.?)', :root => :ref_forms).value_with_reference_text_removed.should == 'a.b.?'
    end
    it "should parse one initial followed by ?" do
      r = @grammar.parse('(w?)', :root => :ref_forms)
      @grammar.parse('(w?)', :root => :ref_forms).value_with_reference_text_removed.should == 'w?'
    end
    it "should parse certain phrases explicitly" do
      for form in ['caste?', 'wing', 'no sex or caste given', 'no caste mentioned', 'no caste', 'no caste or sex given', 'no caste given']
        @grammar.parse("(#{form})", :root => :ref_forms).value_with_reference_text_removed.should == form
      end
    end
    it "should parse these combinations" do
      ['q. ergatoid', 'q.m. ergatoid'].each do |form|
        @grammar.parse("(#{form})", :root => :ref_forms).value_with_reference_text_removed.should == form
      end
    end
    it "should parse one phrase without parentheses" do
      @grammar.parse('no caste given', :root => :ref_forms).value_with_reference_text_removed.should == 'no caste given'
    end

  end

  describe "Pages" do
    it "should handle a PLoS ONE 'page number'" do
      @grammar.parse('e21031', :root => :ref_pages).value
    end
    it "should figs on a page" do
      @grammar.parse('8 figs. 7-12', :root => :ref_pages).value
    end
    it "should handle uppercase letter" do
      @grammar.parse('168, fig. B, 1-7', :root => :ref_pages).value
    end
    it "should parse the word 'page' spelled out" do
      @grammar.parse('page 7, figs. 2, 3', :root => :ref_pages)
    end
    it "should parse figure range with roman letter, and number range" do
      @grammar.parse('fig. I,1-4', :root => :ref_pages)
    end
    it "should parse figure range with letters" do
      @grammar.parse('figs. 4a-b', :root => :ref_pages).value_with_reference_text_removed.should == 'figs. 4a-b'
    end
    it "should parse uppercase figure range" do
      @grammar.parse('figs. 39B-C', :root => :ref_pages).value_with_reference_text_removed.should == 'figs. 39B-C'
    end
    it "should parse uppercase figure range" do
      @grammar.parse('figs. A-D', :root => :ref_pages).value_with_reference_text_removed.should == 'figs. A-D'
    end
    it "should parse spaces around the hyphen" do
      @grammar.parse('figs. 1 - 4', :root => :ref_pages).value_with_reference_text_removed.should == 'figs. 1 - 4'
    end
    it "should parse pages" do
      @grammar.parse('227', :root => :ref_pages).value_with_reference_text_removed.should == '227'
    end
    it "should parse pages with figures" do
      @grammar.parse('227, figs. 12, 35', :root => :ref_pages).value_with_reference_text_removed.should == '227, figs. 12, 35'
    end
    it "should parse pages that merely indicate the figures on a page" do
      @grammar.parse('193, figs.', :root => :ref_pages).value_with_reference_text_removed.should == '193, figs.'
    end
    it "should parse pages with three figures" do
      @grammar.parse('227, figs. 12, 35, 104', :root => :ref_pages).value_with_reference_text_removed.should == '227, figs. 12, 35, 104'
    end
    it "should parse pages with one figure" do
      @grammar.parse('227, fig. 12', :root => :ref_pages).value_with_reference_text_removed.should == '227, fig. 12'
    end
    it "should parse pages with a range of pages" do
      @grammar.parse('227-228', :root => :ref_pages).value_with_reference_text_removed.should == '227-228'
    end
    it "should parse pages with a range of figures" do
      @grammar.parse('227, fig. 12-3', :root => :ref_pages).value_with_reference_text_removed.should == '227, fig. 12-3'
    end
    it "should parse pages with (in key)" do
      @grammar.parse('227 (in key)', :root => :ref_pages).value_with_reference_text_removed.should == '227 (in key)'
    end
    it "should parse pages with (in key) even without space" do
      @grammar.parse('227(in key)', :root => :ref_pages).value_with_reference_text_removed.should == '227(in key)'
    end
    it "should parse pages with (diagnosis in key)" do
      @grammar.parse('227 (diagnosis in key)', :root => :ref_pages).value_with_reference_text_removed.should == '227 (diagnosis in key)'
    end
    it "should parse pages with (footnote)" do
      @grammar.parse('227 (footnote)', :root => :ref_pages).value_with_reference_text_removed.should == '227 (footnote)'
    end
    it "should parse pages with (in table), followed by another page" do
      @grammar.parse('227 (in table), 6', :root => :ref_pages).value_with_reference_text_removed.should == '227 (in table), 6'
    end
    it "should parse pages with (in table)" do
      @grammar.parse('227 (in table)', :root => :ref_pages).value_with_reference_text_removed.should == '227 (in table)'
    end
    it "should parse pages with Roman numerals" do
      @grammar.parse('xxxix', :root => :ref_pages).value_with_reference_text_removed.should == 'xxxix'
    end
    it "should parse pages with plates and figure numbers" do
      @grammar.parse('18, pl. 1, fig. 19', :root => :ref_pages).value_with_reference_text_removed.should == '18, pl. 1, fig. 19'
    end
    it "should parse pages with missing space" do
      @grammar.parse('18, pl.1, fig. 19', :root => :ref_pages).value_with_reference_text_removed.should == '18, pl.1, fig. 19'
    end
    it "should parse pages with plates and figure numbers separated by semicolons" do
      @grammar.parse('215, pl. 15, figs. 9-13; pl. 4, fig. 3', :root => :ref_pages).value_with_reference_text_removed.should == '215, pl. 15, figs. 9-13; pl. 4, fig. 3'
    end
    it "should handle figures with letters" do
      @grammar.parse(%{7, figs. 4b, 5b, 6b}, :root => :ref_pages).value_with_reference_text_removed.should == '7, figs. 4b, 5b, 6b'
    end
    it "should handle 'no.'" do
      @grammar.parse('no. 1651', :root => :ref_pages).value_with_reference_text_removed.should == 'no. 1651'
    end
    it "should handle 'page?'" do
      @grammar.parse('page?', :root => :ref_pages).value_with_reference_text_removed.should == 'page?'
    end

    describe "and years" do
      it "can consider a year a page number instead of a citation_year" do
        ['1758', '1843', '1933', '2000', '2100'].each do |year|
          @grammar.parse(year, :root => :ref_pages)
          @grammar.parse(year, :root => :citation_year)
        end
      end
      it "should not consider a number that isn't a year a year, but a page number" do
        @grammar.parse('9908', :root => :ref_pages)
        lambda {@grammar.parse('9908', :root => :citation_year)}.should raise_error Citrus::ParseError
      end
      it "should not consider a year ending in a letter or colon as a page number" do
        lambda {@grammar.parse('1758d', :root => :ref_pages)}.should raise_error(Citrus::ParseError)
        @grammar.parse('1758d', :root => :citation_year)
        lambda {@grammar.parse('1758:', :root => :ref_pages)}.should raise_error(Citrus::ParseError)
      end
    end

  end

  describe "References with notes" do
    it "should handle a simple phrase" do
      @grammar.parse(%{Heer, 1870: 78 (family unresolved)}, :root => :reference).value_with_reference_text_removed.should == {
        :author_names => ['Heer'], :year => '1870', :pages => '78',
        :notes => [[{:phrase => 'family unresolved'}]]
      }
    end
    it "should handle multiple phrase with a taxon name" do
      @grammar.parse(%{Heer, 1870: 78 (as *<i>Myrmecium</i>, incorrect subsequent spelling)}, :root => :reference).value_with_reference_text_removed.should == {
        :author_names => ['Heer'], :year => '1870', :pages => '78',
        :notes => [[
          {:phrase => 'as', :delimiter => ' '},
          {:genus_name => 'Myrmecium', :fossil => true},
          {:phrase => ', incorrect subsequent spelling'},
      ]]
      }
    end
    it "should handle a bracketed note that begins with a lowercase character" do
      @grammar.parse(%{Emery, 1909c: 355 [as "group" of Ponerinae]}, :root => :reference).value_with_reference_text_removed.should == {
        :author_names => ['Emery'], :year => '1909c', :pages => '355',
        :notes => [[
          {:phrase => 'as', :delimiter => ' '},
          {:phrase => '"group"', :delimiter => ' '},
          {:phrase => 'of', :delimiter => ' '},
          {:family_or_subfamily_name => 'Ponerinae'},
          {:bracketed => true},
        ]]
      }
    end
    it "should not consider bracketed text starting with a capital letter as being a note for the reference" do
      lambda {@grammar.parse(%{Emery, 1909c: 355 [Junior homonym]}, :root => :reference)}.should raise_error(Citrus::ParseError)
    end

    it "should handle both parenthesized and bracketed notes for the same reference" do
      @grammar.parse('Kusnezov, 1964: 62 (alternatively spelled Palaeoattini, p. 146) [as subdivision of tribe Attini]', :root => :reference).value_with_reference_text_removed.should == {
        :author_names => ['Kusnezov'], :year => '1964', :pages => '62',
        :notes => [
          [ {:phrase => 'alternatively spelled', :delimiter => ' '},
            {:tribe_name => 'Palaeoattini'},
            {:phrase => ', p', :delimiter => '. '},
            {:phrase => '146'},
          ], [
            {:phrase => 'as subdivision of tribe', :delimiter => ' '},
            {:tribe_name => 'Attini'},
            {:bracketed => true},
          ]
        ]
      }
    end

    it "should handle a reference inside a reference note" do
      @grammar.parse(%{Brown, 1960a: 167 (these previously provisional synonyms in Brown, 1958h: 13)}, :root => :references).value
    end

    it "should handle multiple references with notes" do
      @grammar.parse(%{Heer, 1870: 78 (as *<i>Myrmecium</i>, incorrect subsequent spelling); Heer, 1870: 78 (family unresolved)}, :root => :references).value_with_reference_text_removed.should == {
        :references => [
          {:author_names => ['Heer'], :year => '1870', :pages => '78',
            :notes => [[
              {:phrase => 'as', :delimiter => ' '},
              {:genus_name => 'Myrmecium', :fossil => true},
              {:phrase => ', incorrect subsequent spelling'},
            ]]
          },
          {:author_names => ['Heer'], :year => '1870', :pages => '78',
            :notes => [[
              {:phrase => 'family unresolved'},
            ]]
          },
        ]
      }
    end
  end

  it "should return the text of what was parsed" do
    string = 'Eguchi, 2008: 238 (s.w.ergatoid q.)'
    @grammar.parse(string, :root => :reference).value_with_reference_text_removed.should == 
      {:author_names => ['Eguchi'], :year => '2008', :pages => '238', :forms => 's.w.ergatoid q.'}
    @grammar.parse(string, :root => :reference).value.should == 
      {:author_names => ['Eguchi'], :year => '2008', :pages => '238', :forms => 's.w.ergatoid q.',
       :reference_text => string}
  end

  describe "deep_delete_reference_text" do
    it "shouldn't mess with a nonhash" do
      2.deep_delete_reference_text.should == 2
    end
    it "shouldn't mess with a hash without the key" do
      {:foo => :bar}.deep_delete_reference_text.should == {:foo => :bar}
    end
    it "should delete the key" do
      {:foo => :bar, :reference_text => 1}.deep_delete_reference_text.should == {:foo => :bar}
    end
    it "should delete the key in an array of hashes" do
      [{:foo => :bar, :reference_text => 1}].deep_delete_reference_text.should == [{:foo => :bar}]
    end
    it "handle this" do
      data = {:a => {:reference_text=> '1'}}
      data.deep_delete_reference_text.should == {:a => {}}
    end
  end

end
