# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Importer do
  before do
    @importer = Bolton::Catalog::Importer.new
  end

  describe "Parsing" do
    before do
      @grammar = mock
      @importer.stub(:grammar).and_return @grammar
    end

    it "should allow parsing a specific rule, but returning any matching rule if that one is not matched" do
      @importer.stub(:grammar).and_return Bolton::Catalog::Subfamily::Grammar
      @importer.parse('UPPERCASE LINE', :tribe_section)[:type].should == :uppercase_line
    end

    it "should work when the specific rule matches" do
      @grammar.stub(:parse).with("specific rule match", :root => :specific_rule).
        and_return stub(:value => :success)
      @importer.parse("specific rule match", :specific_rule).should == :success
    end
  end

  describe "Cleaning up taxonomic history" do
    it "should remove all attributes and spans" do
      @importer.clean_taxonomic_history(
%{<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>} +
%{<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:} +
%{-36.0pt'><b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:} +
%{normal'><span style='color:red'>lundii</span></i></b><i style='mso-bidi-font-style:} +
%{normal'>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger,} +
%{1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.).} +
%{Combination in <i style='mso-bidi-font-style:normal'>Atta</i>: Roger, 1863a:} +
%{200; in <i style='mso-bidi-font-style:normal'>Atta (Acromyrmex</i>): Forel,} +
%{1885a: 356; in <i style='mso-bidi-font-style:normal'>Acromyrmex</i>: Forel,} +
%{1913l: 237. Senior synonym of <i style='mso-bidi-font-style:normal'>bonariensis</i>:} +
%{Gallardo, 1916d: 331; of <i style='mso-bidi-font-style:normal'>risii</i>:} +
%{Santschi, 1925a: 384; of <i style='mso-bidi-font-style:normal'>dubia</i>:} +
%{Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal} +
%{plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>boliviensis,} +
%{carli, decolor, parallelus</span></i>.</p>}
      ).should == 
%{<p><b>Aneuretinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p><b><i>lundii</i></b><i>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger,} +
%{1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.).} +
%{Combination in <i>Atta</i>: Roger, 1863a:} +
%{200; in <i>Atta (Acromyrmex</i>): Forel,} +
%{1885a: 356; in <i>Acromyrmex</i>: Forel,} +
%{1913l: 237. Senior synonym of <i>bonariensis</i>:} +
%{Gallardo, 1916d: 331; of <i>risii</i>:} +
%{Santschi, 1925a: 384; of <i>dubia</i>:} +
%{Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal} +
%{plus <i>boliviensis,} +
%{carli, decolor, parallelus</i>.</p>}
    end
  end

  describe "normalization" do
    it "should do normalization in the right order" do
      @importer.normalize("<b><i><span style='color:red'>stefanschoedli</span></i></b><i>.[<span style='color:red'> </span><span style='color:black'>Forelophilus stefanschoedli </span></i><span style='color:black'>Zettel &amp; Zimmermann et al., 2007: 22, figs. 1, 2, 4-9 (s.w.) PHILIPPINES (Mindanao).<o:p></o:p></span>").should == %{<i>stefanschoedli</i>. <i>Forelophilus stefanschoedli</i> Zettel & Zimmermann, <i>et al.</i>, 2007: 22, figs. 1, 2, 4-9 (s.w.) PHILIPPINES (Mindanao).}
    end

    it "should do ending punctuation fix in the right order" do
      @importer.normalize(%{<i style="mso-bidi-font-style:normal"><span lang="EN-GB">Noonilla</span></i><span lang="EN-GB"> in Leptanillinae, Leptanillini: Bolton, 1990b: 276; Hölldobler & Wilson, 1990: 12; Bolton, 1994: 70; Bolton, 1995b: 292; </span>}).should == %{<i>Noonilla</i> in Leptanillinae, Leptanillini: Bolton, 1990b: 276; Hölldobler & Wilson, 1990: 12; Bolton, 1994: 70; Bolton, 1995b: 292.}
    end

    it "should remove red spans" do
      @importer.normalize('<b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>').should == 'SUBFAMILY MARTIALINAE'
    end

    it "should not add additional italics" do
      @importer.normalize("<i style='mso-bidi-font-style:normal'>PARVIMYRMA</i>: see under <b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'>CAREBARA</i></b><i style='mso-bidi-font-style:normal'>.</i>").should ==
"<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>."
    end
    it "should handle nonbreaking spaces at the right time" do
      @importer.normalize(
        %{<i style='mso-bidi-font-style:normal'><span style="mso-spacerun: yes"> </span>nitida. Formica nitida</i> Smith, F. 1859a: 138 (w.) INDONESIA (Aru I.). [<b style='mso-bidi-font-weight:normal'>Unresolved junior primary homonym</b> of <i style='mso-bidi-font-style:normal'>Formica nitida</i> Razoumowsky, 1789: 427.] Junior synonym of <i style='mso-bidi-font-style:normal'>quadriceps</i>: Mayr, 1863: 403.}).should ==
        "<i>nitida</i>. <i>Formica nitida</i> Smith, F. 1859a: 138 (w.) INDONESIA (Aru I.). [Unresolved junior primary homonym of <i>Formica nitida</i> Razoumowsky, 1789: 427.] Junior synonym of <i>quadriceps</i>: Mayr, 1863: 403."
    end

    it "should change ending comma to period" do
      @importer.normalize("foo,").should == 'foo.' 
    end
    it "should change ending semicolon to period" do
      @importer.normalize("foo;").should == 'foo.' 
    end
    it "should remove spaces before periods" do
      @importer.normalize("foo . bar.").should == 'foo. bar.' 
    end
    it "should convert character entities to characters" do
      @importer.normalize("&quot; &amp;").should == %{" &}
    end
    it "should convert nonbreaking spaces to spaces" do
      @importer.normalize("<i>&nbsp;foo</i>").should == %{<i>foo</i>}
    end
    it "should convert this weird apostrophe-like thing" do
      @importer.normalize("’").should == "'"
    end
    it "should convert this weird quote-like thing" do
      @importer.normalize('”').should == '"'
    end
    it "should convert this other weird quote-like thing" do
      @importer.normalize('“').should == '"'
    end
    it "should convert this em-dash to a hyphen" do
      @importer.normalize('–').should == '-'
    end

    it "convert double periods to single" do
      @importer.normalize("..").should == "."
    end
    it "should remove abnormal things" do
      @importer.normalize(
"<b><i><span style='color:red'>bahianus</span></i></b><i>.  \nForelius bahianus</i> Cuezzo, 2000: 227, figs. 12, 35 (w.q.) BRAZIL.<span> </span>").should ==
"<i>bahianus</i>. <i>Forelius bahianus</i> Cuezzo, 2000: 227, figs. 12, 35 (w.q.) BRAZIL."
    end

    it "should handle italicized nomen nudum with purple" do
      @importer.normalize(%{Material of the <i>nomen nudum <span style="color:purple">cinereoglebaria</span></i>}).should ==
        "Material of the <i>nomen nudum</i> <i>cinereoglebaria</i>"
    end

    describe "removing bold" do

      it "should remove bold tags with attributes" do
        @importer.remove_bold(%{<b style="mso-bidi-font-weight:normal">foo</b>}).should == "foo"
      end

      it "should remove bold tags without attributes" do
        @importer.remove_bold(%{<b>foo</b>}).should == "foo"
      end

      it "should leave other tags beginning with 'b' alone" do
        @importer.remove_bold(%{<blink>foo</blink>}).should == "<blink>foo</blink>"
      end

    end

    describe "normalizing italics" do
      describe "normalizing incertae sedis italicization" do
        it "should be recognized when the incertae sedis part is a bit different" do
          @importer.normalize_italics(%{Genus <i>incertae sedis </i>}).should == 'Genus <i>incertae sedis</i> '
        end
        it "should be recognized when the incertae sedis part is a bit different" do
          @importer.normalize_italics(%{Genus<i> incertae sedis</i>}).should == 'Genus <i>incertae sedis</i>'
        end
        it "should fix a misplaced italic tag" do
          @importer.normalize_italics("Genus<i>) incertae sedis</i>").should == "Genus) <i>incertae sedis</i>"
        end
      end
      it "should move colon outside italics" do
        @importer.normalize_italics('<i>ASKETOGENYS:</i>').should == '<i>ASKETOGENYS</i>:'
      end
      it "should move commas outside italics" do
        @importer.normalize_italics('<i>antiqua,</i> *<i>baltica,</i> *<i>parvula</i>').should == '<i>antiqua</i>, *<i>baltica</i>, *<i>parvula</i>'
      end
      it "should remove empty italics" do
        @importer.normalize_italics('<i>tianshanica</i><i>. Formica tianshanica</i> Seifert & Schultz, 2009: 267, figs. 9, 16 (w.) KYRGHIZSTAN.<i> </i>').should ==
          '<i>tianshanica</i>. <i>Formica tianshanica</i> Seifert & Schultz, 2009: 267, figs. 9, 16 (w.) KYRGHIZSTAN.'
      end
      it "should really remove empty italics" do
        @importer.normalize_italics('<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>.<i></i>').should == '<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>.'
      end
      it "should italicize comma-delimited words separately" do
        @importer.italicize_comma_separated_items_separately('<i>transversa, clara</i>').should == '<i>transversa</i>, <i>clara</i>'
      end
      it "should italicize comma-delimited words separately, in multiple groups" do
        @importer.italicize_comma_separated_items_separately('<i>transversa, clara</i> and also <i>a, b</i>').should == '<i>transversa</i>, <i>clara</i> and also <i>a</i>, <i>b</i>'
      end
      it "should italicize comma-delimited words separately, with fossil flag" do
        @importer.italicize_comma_separated_items_separately('<i>transversa, *clara</i>').should == '<i>transversa</i>, *<i>clara</i>'
      end
      it "should remove attributes from italic tags" do
        @importer.normalize_italics(%{<i style="mso-bidi-font-style:normal">}).should == "<i>"
      end
      it "should unitalicize Genus at the beginning of the line" do
        @importer.normalize_italics(%{<i>Genus PARVIMYRMA</i>}).should == 'Genus <i>PARVIMYRMA</i>'
      end
      it "should italicize the species name separately from the protonym name" do
        @importer.normalize_italics(%{<i>foo. bar</i>}).should == "<i>foo</i>. <i>bar</i>"
      end
      it "should not mess up when the species name is already separately italicized" do
        @importer.normalize_italics(%{<i>foo</i>. <i>bar</i>}).should == "<i>foo</i>. <i>bar</i>"
      end
      it "italicize the species name separately from the protonym name, when fossil" do
        @importer.normalize_italics(%{*<i>foo. *bar</i>}).should == "*<i>foo</i>. *<i>bar</i>"
      end
      it "should move italics to delimit words, and not include spaces or punctuation at beginning or end" do
        @importer.normalize_italics("<i>.  bahianus</i>").should == ".  <i>bahianus</i>"
      end
      it "should move end italic tag" do
        @importer.normalize_italics(%{<i>foo. </i>}).should == "<i>foo</i>. "
      end

      # Seems a bit drastic. Perhaps should just handle in specific grammar rule (like species headline)
      #it "italicize the species name separately even without a period at its end (and add it)" do
        #@importer.normalize_italics(%{<i>foo bar</i>}).should == "<i>foo</i>. <i>bar</i>"
      #end

      it "italicize the species name separately even if its a subspecies" do
        @importer.normalize_italics(%{#<i>foo. bar</i>}).should == "#<i>foo</i>. <i>bar</i>"
      end
      it "should put italic tag outside subgenus parentheses" do
        @importer.normalize_italics('(Serviformica</i>)').should == '(Serviformica)</i>'
      end
      it "should not put italic tag outside parens enclosing subgenus parentheses" do
        @importer.normalize_italics('(<i>Atta (Serviformica</i>))').should == '(<i>Atta</i> <i>(Serviformica)</i>)'
      end
      it "should handle when the italic tag comes after two parens" do
        @importer.normalize(%{Seifert, 1990: 1 (supplement to European <i>L. (Chthonolasius))</i>.}).should == 'Seifert, 1990: 1 (supplement to European <i>L. (Chthonolasius)</i>).'
      end
      it "should remove space between italic and label" do
        @importer.normalize('<i>&nbsp;nitida. Formica').should == '<i>nitida</i>. <i>Formica'
      end

      describe "Nomen nudum" do
        it "should italicize 'nomen nudum' separately" do
          @importer.italicize_nomen_nudum_separately('<i>nomen nudum foo</i>').should == '<i>nomen nudum</i> <i>foo</i>'
        end
        it "should italicize 'nomen nudum' correctly" do
          @importer.normalize_italics('<i>foo</i>. <i>Nomen nudum. F. rufibarbis</i> var. <i>occidentalis</i>').should ==
                                      '<i>foo</i>. <i>Nomen nudum</i>. <i>F. rufibarbis</i> var. <i>occidentalis</i>'
        end
      end
  
      it "should not put /i at end of name outside parentheses" do
        text = "(junior synonym of <i>Monomorium (Adlerzia) froggatti</i>)"
        @importer.normalize_italics(text).should == text
      end
      it "should wrap entire abbreviated genus + subgenus in parentheses in italics" do
        @importer.normalize_italics("<i>F</i>. (<i>Serviformica</i>)").should == '<i>F. (Serviformica)</i>'
      end
    end

    describe "squishing spaces" do
      it "should squish multiple spaces to one" do
        @importer.squish_spaces(" a\n b ").should == "a b"
      end
      it "should convert nonbreaking spaces to spaces" do
        @importer.squish_spaces('a  b').should == 'a b'
      end
    end

    describe "removing inner paragraphs" do
      it "should remove normal inner paragraphs" do
        @importer.remove_inner_paragraphs("a<p>   </p>b").should == "ab"
      end

      it "should remove 'o:' paragraphs" do
        @importer.remove_inner_paragraphs("a<o:p>   </o:p>b").should == "ab"
      end
    end

    describe "removing spans" do
      it "should remove 'color:black' in single quotes" do
        @importer.remove_spans("a<span style='color:black'>b</span>c").should == 'abc'
      end
    end

    describe "fixing et al." do
      ['<i>et al.</i>', '<i>et al</i>.'].each do |et_al|
        it "should convert #{et_al} to '<i>et al.</i>" do
          @importer.fix_et_al(et_al).should == '<i>et al.</i>'
        end
      end
      it "should convert ' et al.' to ' <i>et al.</i>" do
        @importer.fix_et_al(' et al.').should == ' <i>et al.</i>'
      end
      it "should add a comma before 'et al.', if necessary" do
        @importer.fix_et_al('Bolton <i>et al.</i>').should == 'Bolton, <i>et al.</i>'
      end
      it "should handle multiple occurences in same string" do
        @importer.fix_et_al('Bolton et al. Ward et al. Fisher et al. Blum <i>et al</i>.').should ==
              'Bolton, <i>et al.</i> Ward, <i>et al.</i> Fisher, <i>et al.</i> Blum, <i>et al.</i>'
      end
    end

    describe "Add space after semicolon" do
      it "should work" do
        @importer.normalize('238;Bolton').should == '238; Bolton'
      end
    end

    describe "Removing unmatched brackets and parentheses" do
      it "should remove a mismatched brackets" do
        @importer.remove_mismatched_brackets("[a]]").should == '[a]'
        @importer.remove_mismatched_brackets("[[a]").should == '[a]'
        @importer.remove_mismatched_brackets("a]").should == 'a'
        @importer.remove_mismatched_brackets("[a").should == 'a'
        @importer.remove_mismatched_brackets("(a").should == 'a'
        @importer.remove_mismatched_brackets("(a(b").should == 'ab'
      end
    end

    it "should put fossil_tags inside HTML tags" do
      Bolton::Catalog::Importer.new.clean_taxonomic_history(
%{<p><b>*<i>atta</i></b></p>}).should == %{<p><b><i>&dagger;atta</i></b></p>}
    end

    it "should put fossil_tags inside HTML tags" do
      Bolton::Catalog::Importer.new.clean_taxonomic_history(
%{<p><b>*<i>atta</i></b></p>}).should == %{<p><b><i>&dagger;atta</i></b></p>}
    end

  end

  describe "Converting from parsed format to Text format" do
    it "should handle an empty string" do
      @importer.convert_parser_output_to_taxt({}).should == ''
    end
    it "should handle a phrase" do
      data = [{:phrase => 'Phrase'}]
      @importer.convert_parser_output_to_taxt(data).should == 'Phrase'
    end
    it "should handle a phrase inside a text" do
      data = [{:text => [{:phrase => 'Phrase'}]}]
      @importer.convert_parser_output_to_taxt(data).should == 'Phrase'
    end

    describe "Citations" do
      it "should handle a citation" do
        reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
        data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244'}]
        @importer.convert_parser_output_to_taxt(data).should == "{ref #{reference.id}}: 244"
      end
      it "should handle a citation whose reference wasn't matched" do
        bolton_reference = Factory :bolton_reference, :authors => 'Latreille', :citation_year => '1809'
        data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244'}]
        @importer.convert_parser_output_to_taxt(data).should == "{ref? Latreille, 1809}: 244"
      end
      it "should handle a citation whose reference wasn't found" do
        data = [{:author_names => ['Latreille'], :year => '1809', :pages => '244'}]
        @importer.convert_parser_output_to_taxt(data).should == "{ref? Latreille, 1809}: 244"
      end
      it "should handle a nested citation (i.e., without year)" do
        reference = Factory :article_reference, :bolton_key_cache => 'Nel Perrault 2004'
        data = [{
          :author_names => ["Nel", "Perrault"],
          :in => {:author_names => ["Nel", "Perrault", "Perrichot", "Néraudeau"], :year => "2004"},
          :pages => "24"}]
        @importer.convert_parser_output_to_taxt(data).should == "{ref #{reference.id}}: 24"
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
      @importer.convert_parser_output_to_taxt(data).should == "Formicidae as family: {ref #{reference.id}}: 124 [Formicariae]; all subsequent authors"
    end

    describe "Bracketed items" do
      it "should handle a bracketed text item" do
        data = [{:opening_bracket => '['}, {:phrase => 'all rights reserved'}, {:closing_bracket => ']'}]
        @importer.convert_parser_output_to_taxt(data).should == "[all rights reserved]"
      end
      it "should handle a bracketed text item nested in a text" do
        data = [:text => [{:opening_bracket => '['}, {:phrase => 'all rights reserved'}, {:closing_bracket => ']'}], :delimiter => ': ']
        @importer.convert_parser_output_to_taxt(data).should == "[all rights reserved]: "
      end
    end

    describe "Unparseable items" do
      it "should handle it" do
        data = [{:unparseable=>"?: Swainson & Shuckard, 1840: 173"}]
        @importer.convert_parser_output_to_taxt(data).should == "{? ?: Swainson & Shuckard, 1840: 173}"
      end
    end

    describe "Taxon names" do
      [:order_name, :family_or_subfamily_name, :tribe_name, :subtribe_name, :collective_group_name, :genus_name].each do |key|
        it "should handle #{key}" do
          @importer.convert_parser_output_to_taxt([key => 'Formicariae']).should == "Formicariae"
        end
      end
      it "should handle taxon names with other text" do
        @importer.convert_parser_output_to_taxt([
          {:family_or_subfamily_name => 'Formicariae', :delimiter => ' '},
          {:phrase => 'or', :delimiter => ' '},
          {:family_or_subfamily_name => 'Formicidae'},
        ]).should == "Formicariae or Formicidae"
      end
    end

  end
end
