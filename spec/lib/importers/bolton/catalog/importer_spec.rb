# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Importer.new
  end

  describe "Parsing" do
    before do
      @grammar = double
      allow(@importer).to receive(:grammar).and_return @grammar
    end

    it "should allow parsing a specific rule, but returning any matching rule if that one is not matched" do
      allow(@importer).to receive(:grammar).and_return Importers::Bolton::Catalog::Subfamily::Grammar
      expect(@importer.parse('UPPERCASE LINE', :tribe_section)[:type]).to eq(:uppercase_line)
    end

    it "should work when the specific rule matches" do
      allow(@grammar).to receive(:parse).with("specific rule match", :root => :specific_rule).
        and_return double(:value => :success)
      expect(@importer.parse("specific rule match", :specific_rule)).to eq(:success)
    end
  end

  describe "normalization" do
    it "should do normalization in the right order" do
      expect(@importer.normalize("<b><i><span style='color:red'>stefanschoedli</span></i></b><i>.[<span style='color:red'> </span><span style='color:black'>Forelophilus stefanschoedli </span></i><span style='color:black'>Zettel &amp; Zimmermann et al., 2007: 22, figs. 1, 2, 4-9 (s.w.) PHILIPPINES (Mindanao).<o:p></o:p></span>")).to eq(%{<i>stefanschoedli</i>. <i>Forelophilus stefanschoedli</i> Zettel & Zimmermann, <i>et al.</i>, 2007: 22, figs. 1, 2, 4-9 (s.w.) PHILIPPINES (Mindanao).})
    end

    it "should do ending punctuation fix in the right order" do
      expect(@importer.normalize(%{<i style="mso-bidi-font-style:normal"><span lang="EN-GB">Noonilla</span></i><span lang="EN-GB"> in Leptanillinae, Leptanillini: Bolton, 1990b: 276; Hölldobler & Wilson, 1990: 12; Bolton, 1994: 70; Bolton, 1995b: 292; </span>})).to eq(%{<i>Noonilla</i> in Leptanillinae, Leptanillini: Bolton, 1990b: 276; Hölldobler & Wilson, 1990: 12; Bolton, 1994: 70; Bolton, 1995b: 292.})
    end

    it "should remove red spans" do
      expect(@importer.normalize('<b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>')).to eq('SUBFAMILY MARTIALINAE')
    end

    it "should not add additional italics" do
      expect(@importer.normalize("<i style='mso-bidi-font-style:normal'>PARVIMYRMA</i>: see under <b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'>CAREBARA</i></b><i style='mso-bidi-font-style:normal'>.</i>")).to eq("<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>.")
    end
    it "should handle nonbreaking spaces at the right time" do
      expect(@importer.normalize(
        %{<i style='mso-bidi-font-style:normal'><span style="mso-spacerun: yes"> </span>nitida. Formica nitida</i> Smith, F. 1859a: 138 (w.) INDONESIA (Aru I.). [<b style='mso-bidi-font-weight:normal'>Unresolved junior primary homonym</b> of <i style='mso-bidi-font-style:normal'>Formica nitida</i> Razoumowsky, 1789: 427.] Junior synonym of <i style='mso-bidi-font-style:normal'>quadriceps</i>: Mayr, 1863: 403.})).to eq(
        "<i>nitida</i>. <i>Formica nitida</i> Smith, F. 1859a: 138 (w.) INDONESIA (Aru I.). [Unresolved junior primary homonym of <i>Formica nitida</i> Razoumowsky, 1789: 427.] Junior synonym of <i>quadriceps</i>: Mayr, 1863: 403."
      )
    end

    it "should change ending comma to period" do
      expect(@importer.normalize("foo,")).to eq('foo.')
    end
    it "should change ending semicolon to period" do
      expect(@importer.normalize("foo;")).to eq('foo.')
    end
    it "should remove spaces before periods" do
      expect(@importer.normalize("foo . bar.")).to eq('foo. bar.')
    end
    it "should convert character entities to characters" do
      expect(@importer.normalize("&quot; &amp;")).to eq(%{" &})
    end
    it "should convert nonbreaking spaces to spaces" do
      expect(@importer.normalize("<i>&nbsp;foo</i>")).to eq(%{<i>foo</i>})
    end
    it "should convert this weird apostrophe-like thing" do
      expect(@importer.normalize("’")).to eq("'")
    end
    it "should convert this weird quote-like thing" do
      expect(@importer.normalize('”')).to eq('"')
    end
    it "should convert this other weird quote-like thing" do
      expect(@importer.normalize('“')).to eq('"')
    end
    it "should convert this em-dash to a hyphen" do
      expect(@importer.normalize('–')).to eq('-')
    end

    it "convert double periods to single" do
      expect(@importer.normalize("..")).to eq(".")
    end
    it "should remove abnormal things" do
      expect(@importer.normalize(
"<b><i><span style='color:red'>bahianus</span></i></b><i>.  \nForelius bahianus</i> Cuezzo, 2000: 227, figs. 12, 35 (w.q.) BRAZIL.<span> </span>")).to eq("<i>bahianus</i>. <i>Forelius bahianus</i> Cuezzo, 2000: 227, figs. 12, 35 (w.q.) BRAZIL.")
    end

    it "should handle italicized nomen nudum with purple" do
      expect(@importer.normalize(%{Material of the <i>nomen nudum <span style="color:purple">cinereoglebaria</span></i>})).to eq(
        "Material of the <i>nomen nudum</i> <i>cinereoglebaria</i>"
      )
    end

    describe "removing bold" do

      it "should remove bold tags with attributes" do
        expect(@importer.remove_bold(%{<b style="mso-bidi-font-weight:normal">foo</b>})).to eq("foo")
      end

      it "should remove bold tags without attributes" do
        expect(@importer.remove_bold(%{<b>foo</b>})).to eq("foo")
      end

      it "should leave other tags beginning with 'b' alone" do
        expect(@importer.remove_bold(%{<blink>foo</blink>})).to eq("<blink>foo</blink>")
      end

    end

    describe "normalizing italics" do
      describe "normalizing incertae sedis italicization" do
        it "should be recognized when the incertae sedis part is a bit different" do
          expect(@importer.normalize_italics(%{Genus <i>incertae sedis </i>})).to eq('Genus <i>incertae sedis</i> ')
        end
        it "should be recognized when the incertae sedis part is a bit different" do
          expect(@importer.normalize_italics(%{Genus<i> incertae sedis</i>})).to eq('Genus <i>incertae sedis</i>')
        end
        it "should fix a misplaced italic tag" do
          expect(@importer.normalize_italics("Genus<i>) incertae sedis</i>")).to eq("Genus) <i>incertae sedis</i>")
        end
      end
      it "should move colon outside italics" do
        expect(@importer.normalize_italics('<i>ASKETOGENYS:</i>')).to eq('<i>ASKETOGENYS</i>:')
      end
      it "should move commas outside italics" do
        expect(@importer.normalize_italics('<i>antiqua,</i> *<i>baltica,</i> *<i>parvula</i>')).to eq('<i>antiqua</i>, *<i>baltica</i>, *<i>parvula</i>')
      end
      it "should remove empty italics" do
        expect(@importer.normalize_italics('<i>tianshanica</i><i>. Formica tianshanica</i> Seifert & Schultz, 2009: 267, figs. 9, 16 (w.) KYRGHIZSTAN.<i> </i>')).to eq(
          '<i>tianshanica</i>. <i>Formica tianshanica</i> Seifert & Schultz, 2009: 267, figs. 9, 16 (w.) KYRGHIZSTAN.'
        )
      end
      it "should really remove empty italics" do
        expect(@importer.normalize_italics('<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>.<i></i>')).to eq('<i>PARVIMYRMA</i>: see under <i>CAREBARA</i>.')
      end
      it "should italicize comma-delimited words separately" do
        expect(@importer.italicize_comma_separated_items_separately('<i>transversa, clara</i>')).to eq('<i>transversa</i>, <i>clara</i>')
      end
      it "should italicize comma-delimited words separately, in multiple groups" do
        expect(@importer.italicize_comma_separated_items_separately('<i>transversa, clara</i> and also <i>a, b</i>')).to eq('<i>transversa</i>, <i>clara</i> and also <i>a</i>, <i>b</i>')
      end
      it "should italicize comma-delimited words separately, with fossil flag" do
        expect(@importer.italicize_comma_separated_items_separately('<i>transversa, *clara</i>')).to eq('<i>transversa</i>, *<i>clara</i>')
      end
      it "should remove attributes from italic tags" do
        expect(@importer.normalize_italics(%{<i style="mso-bidi-font-style:normal">})).to eq("<i>")
      end
      it "should unitalicize Genus at the beginning of the line" do
        expect(@importer.normalize_italics(%{<i>Genus PARVIMYRMA</i>})).to eq('Genus <i>PARVIMYRMA</i>')
      end
      it "should italicize the species name separately from the protonym name" do
        expect(@importer.normalize_italics(%{<i>foo. bar</i>})).to eq("<i>foo</i>. <i>bar</i>")
      end
      it "should not mess up when the species name is already separately italicized" do
        expect(@importer.normalize_italics(%{<i>foo</i>. <i>bar</i>})).to eq("<i>foo</i>. <i>bar</i>")
      end
      it "italicize the species name separately from the protonym name, when fossil" do
        expect(@importer.normalize_italics(%{*<i>foo. *bar</i>})).to eq("*<i>foo</i>. *<i>bar</i>")
      end
      it "should move italics to delimit words, and not include spaces or punctuation at beginning or end" do
        expect(@importer.normalize_italics("<i>.  bahianus</i>")).to eq(".  <i>bahianus</i>")
      end
      it "should move end italic tag" do
        expect(@importer.normalize_italics(%{<i>foo. </i>})).to eq("<i>foo</i>. ")
      end

      # Seems a bit drastic. Perhaps should just handle in specific grammar rule (like species headline)
      #it "italicize the species name separately even without a period at its end (and add it)" do
        #@importer.normalize_italics(%{<i>foo bar</i>}).should == "<i>foo</i>. <i>bar</i>"
      #end

      it "italicize the species name separately even if its a subspecies" do
        expect(@importer.normalize_italics(%{#<i>foo. bar</i>})).to eq("#<i>foo</i>. <i>bar</i>")
      end
      it "should put italic tag outside subgenus parentheses" do
        expect(@importer.normalize_italics('(Serviformica</i>)')).to eq('(Serviformica)</i>')
      end
      it "should not put italic tag outside parens enclosing subgenus parentheses" do
        expect(@importer.normalize_italics('(<i>Atta (Serviformica</i>))')).to eq('(<i>Atta</i> <i>(Serviformica)</i>)')
      end
      it "should handle when the italic tag comes after two parens" do
        expect(@importer.normalize(%{Seifert, 1990: 1 (supplement to European <i>L. (Chthonolasius))</i>.})).to eq('Seifert, 1990: 1 (supplement to European <i>L. (Chthonolasius)</i>).')
      end
      it "should remove space between italic and label" do
        expect(@importer.normalize('<i>&nbsp;nitida. Formica')).to eq('<i>nitida</i>. <i>Formica')
      end

      describe "Nomen nudum" do
        it "should italicize 'nomen nudum' separately" do
          expect(@importer.italicize_nomen_nudum_separately('<i>nomen nudum foo</i>')).to eq('<i>nomen nudum</i> <i>foo</i>')
        end
        it "should italicize 'nomen nudum' correctly" do
          expect(@importer.normalize_italics('<i>foo</i>. <i>Nomen nudum. F. rufibarbis</i> var. <i>occidentalis</i>')).to eq(
                                      '<i>foo</i>. <i>Nomen nudum</i>. <i>F. rufibarbis</i> var. <i>occidentalis</i>'
          )
        end
      end

      it "should not put /i at end of name outside parentheses" do
        text = "(junior synonym of <i>Monomorium (Adlerzia) froggatti</i>)"
        expect(@importer.normalize_italics(text)).to eq(text)
      end
      it "should wrap entire abbreviated genus + subgenus in parentheses in italics" do
        expect(@importer.normalize_italics("<i>F</i>. (<i>Serviformica</i>)")).to eq('<i>F. (Serviformica)</i>')
      end
    end

    describe "squishing spaces" do
      it "should squish multiple spaces to one" do
        expect(@importer.squish_spaces(" a\n b ")).to eq("a b")
      end
      it "should convert nonbreaking spaces to spaces" do
        expect(@importer.squish_spaces('a  b')).to eq('a b')
      end
    end

    describe "removing inner paragraphs" do
      it "should remove normal inner paragraphs" do
        expect(@importer.remove_inner_paragraphs("a<p>   </p>b")).to eq("ab")
      end

      it "should remove 'o:' paragraphs" do
        expect(@importer.remove_inner_paragraphs("a<o:p>   </o:p>b")).to eq("ab")
      end
    end

    describe "removing spans" do
      it "should remove 'color:black' in single quotes" do
        expect(@importer.remove_spans("a<span style='color:black'>b</span>c")).to eq('abc')
      end
    end

    describe "fixing et al." do
      ['<i>et al.</i>', '<i>et al</i>.'].each do |et_al|
        it "should convert #{et_al} to '<i>et al.</i>" do
          expect(@importer.fix_et_al(et_al)).to eq('<i>et al.</i>')
        end
      end
      it "should convert ' et al.' to ' <i>et al.</i>" do
        expect(@importer.fix_et_al(' et al.')).to eq(' <i>et al.</i>')
      end
      it "should add a comma before 'et al.', if necessary" do
        expect(@importer.fix_et_al('Bolton <i>et al.</i>')).to eq('Bolton, <i>et al.</i>')
      end
      it "should handle multiple occurences in same string" do
        expect(@importer.fix_et_al('Bolton et al. Ward et al. Fisher et al. Blum <i>et al</i>.')).to eq(
              'Bolton, <i>et al.</i> Ward, <i>et al.</i> Fisher, <i>et al.</i> Blum, <i>et al.</i>'
        )
      end
      it "should not get fooled by et- prefix" do
        expect(@importer.fix_et_al('subsp. <i>etrusca</i>')).to eq('subsp. <i>etrusca</i>')
      end
    end

    describe "Add space after semicolon" do
      it "should work" do
        expect(@importer.normalize('238;Bolton')).to eq('238; Bolton')
      end
    end

    describe "Fixing U. S. A." do
      it "should work" do
        expect(@importer.normalize('U. S. A.')).to eq('U.S.A.')
        expect(@importer.normalize('U.S. A.')).to eq('U.S.A.')
      end
    end

    describe "Removing unmatched brackets and parentheses" do
      it "should remove a mismatched brackets" do
        expect(@importer.remove_mismatched_brackets("[a]]")).to eq('[a]')
        expect(@importer.remove_mismatched_brackets("[[a]")).to eq('[a]')
        expect(@importer.remove_mismatched_brackets("a]")).to eq('a')
        expect(@importer.remove_mismatched_brackets("[a")).to eq('a')
        expect(@importer.remove_mismatched_brackets("(a")).to eq('a')
        expect(@importer.remove_mismatched_brackets("(a(b")).to eq('ab')
      end
    end

  end

  it "should remove empty italics even in this mess" do
 expect(@importer.normalize(
%{<b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style='font-size:12.0pt;font-family: "Times New Roman";mso-bidi-font-family:"Times New Roman";color:red'>caniophanoides</span></i></b><b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style='font-size:12.0pt;font-family:"Times New Roman";mso-bidi-font-family: "Times New Roman";color:black'>. </span></i></b><i style="mso-bidi-font-style: normal"><span style='font-size:12.0pt;font-family:"Times New Roman";mso-bidi-font-family: "Times New Roman";color:black'>Strumigenys caniophanoides</span></i><span style='font-size:12.0pt;font-family:"Times New Roman";mso-bidi-font-family: "Times New Roman";color:black'> De Andrade, in Baroni Urbani & De Andrade, 2007: 153, fig. 53 (w.) BHUTAN.<p></p></span>})).to eq("<i>caniophanoides</i>. <i>Strumigenys caniophanoides</i> De Andrade, in Baroni Urbani & De Andrade, 2007: 153, fig. 53 (w.) BHUTAN.")
  end

end
