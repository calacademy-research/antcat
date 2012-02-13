# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::DeepSpeciesGrammar do
  before do
    @grammar = Importers::Bolton::Catalog::Species::DeepSpeciesGrammar
  end

  it "should parse a representative sample" do
    @grammar.parse(%{*<i>tucumanus</i>. *<i>Neoforelius tucumanus</i> var. <i>modesta</i> Kusnezov, 1953b: 330, figs. 1-12, no caste given, BALTIC AMBER (Eocene). [First available use of <i>Forelius maccooki</i> r. <i>fiebrigi</i> var. <i>breviscapa</i> Forel, 1913l: 241; unavailable name.] [Also described as new by Heer, 1850: 142.] Cuezzo, 2000: 216 (q.m.). Combination in *<i>Forelius</i>: Smith, F., 1992c: 95; in <i>Atta</i>: Bolton, 2002: 3. Material referred to <i>rufa</i> by Yarrow, 1955a: 4. Raised to species: Wheeler, W.C. & Wheeler, M., 1954b: 37. Status as species: Creighton, 1960: 1. Mayr, 1886d: 432 (q.m.); Forel, 1886b: xxxix (w.). Junior synonym of <i>pusillus</i>: Creighton, 1950a: 342; Petralia & Vinson, 1980: 386. Subspecies of <i>mccooki</i>: Forel, 1912h: 43. Senior synonym of <i>fiebrigi</i>, <i>pilipes</i> and material of the unavailable name <i>carmelitana</i> referred here: Cuezzo, 2000: 229. [<i>Iridomyrmex maccooki</i> Forel, 1878: 382. <i>Nomen nudum</i>.] [Misspelled as <i>paucistriatus</i> by Kempf, 1972a: 109.] Unidentifiable to genus; <i>incertae sedis</i> in <i>Formica</i>: Bolton, 1995b: 190. [Obviously incorrect.] Revived from synonymy: Kusnezov, 1957b: 16 (in key). Relationship with <i>densiventris</i>: Cole, 1954a: 89. Material of the unavailable names <i>transversa</i>, <i>clara</i> referred here by Dlussky, 1967a: 77. Revived status as species: Bernard, 1967: 298. See also: Bolton, 2000: 1. Current subspecies: nominal plus <i>alpina</i>, <i>whymperi</i>. See also: Cuezzo, 2000: 253. [Another note.]}).value_with_reference_text_removed.should == {
      :type => :species_record,
      :species_group_epithet => 'tucumanus',
      :fossil => true,
      :protonym => {
        :genus_name => 'Neoforelius',
        :species_epithet => 'tucumanus',
        :subspecies => [{:type => 'var.', :subspecies_epithet => 'modesta'}],
        :fossil => true,
        :authorship => [{:author_names => ['Kusnezov'], :year => '1953b', :pages => '330, figs. 1-12', :forms => 'no caste given'}],
        :locality => 'Baltic Amber (Eocene)',
      },
      :history => [
        {:first_available_use_of => {
          :genus_name => 'Forelius',
          :species_epithet => 'maccooki',
          :subspecies => [{:type => 'r.', :subspecies_epithet => 'fiebrigi'}, {:type => 'var.', :subspecies_epithet => 'breviscapa'}],
          :authorship => [{:author_names => ['Forel'], :year => '1913l', :pages => '241'}]
        }},
        {:also_described_as_new => {
          :references => [{:author_names => ['Heer'], :year => '1850', :pages => '142'}]
        }},
        {:references => [
            {:author_names => ['Cuezzo'], :year => '2000', :pages => '216', :forms => 'q.m.'}
        ]},
        {:combinations_in => [
          {:genus_name => 'Forelius', :fossil => true, :references => [{:author_names => ['Smith, F.'], :year => '1992c', :pages => '95'}]},
          {:genus_name => 'Atta', :references => [{:author_names => ['Bolton'], :year => '2002', :pages => '3'}]},
        ]},
        {:material_referred_to => {
          :species_epithet => 'rufa',
          :references => [{:author_names => ['Yarrow'], :year => '1955a', :pages => '4'}]
        }},
        {:raised_to_species =>
          {:references => [{:author_names => ['Wheeler, W.C.', 'Wheeler, M.'], :year => '1954b', :pages => '37'}]}
        },
        {:status_as_species =>
          {:references => [{:author_names => ['Creighton'], :year => '1960', :pages => '1'}]}
        },
        {:references => [
          {:author_names => ['Mayr'], :year => '1886d', :pages => '432', :forms => 'q.m.'},
          {:author_names => ['Forel'], :year => '1886b', :pages => 'xxxix', :forms => 'w.'},
        ]},
        {:synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'pusillus',
            :references => [
              {:author_names => ['Creighton'], :year => '1950a', :pages => '342'},
              {:author_names => ['Petralia', 'Vinson'], :year => '1980', :pages => '386'},
            ]
          }]
        },
        {:subspecies_ofs => [{
          :species => {:species_epithet => 'mccooki'}, :references => [{:author_names => ['Forel'], :year => '1912h', :pages => '43'}]
        }]},
        {:senior_synonym_ofs => [{
          :junior_synonyms => [
            {:species_epithet => 'fiebrigi'},
            {:species_epithet => 'pilipes'},
          ],
          :material_of_unavailable_names_referred_here => [{:species_group_epithet => 'carmelitana'}],
          :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '229'}]
        }]},
        {:nomen_nudum => {
          :genus_name => 'Iridomyrmex', :species_epithet => 'maccooki',
          :authorship => [{:author_names => ['Forel'], :year => '1878', :pages => '382'}]
        }},
        {:misspellings => [{
          :species_epithet => 'paucistriatus',
          :references => [{:author_names => ['Kempf'], :year => '1972a', :pages => '109'}]
        }]},
        {:unidentifiable => {
          :references => [{:author_names => ['Bolton'], :year => '1995b', :pages => '190'}]
        }},
        {:text => [
          {:opening_bracket => '['},
          {:phrase => 'Obviously incorrect', :delimiter => '.'},
          {:closing_bracket => ']'},
        ]},
        {:revived_from_synonymy => {
          :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
        }},
        {:relationship_with => {
          :species_epithet => 'densiventris',
          :references => [{:author_names => ['Cole'], :year => '1954a', :pages => '89'}]
        }},
        {:material_of_unavailable_names_referred_here => {
          :taxa => [{:species_group_epithet => 'transversa'}, {:species_group_epithet => 'clara'}],
          :references => [{:author_names => ['Dlussky'], :year => '1967a', :pages => '77'}]
        }},
        {:revived_status_as_species => {
          :references => [{:author_names => ['Bernard'], :year => '1967', :pages => '298'}]
        }},
        {:see_also => {
          :references => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]
        }},
        {:subspecies => [{:species_group_epithet => 'alpina'}, {:species_group_epithet => 'whymperi'}]},
        {:see_also => {
          :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '253'}]
        }},
        {:text => [
          {:opening_bracket => '['},
          {:phrase => 'Another note', :delimiter => '.'},
          {:closing_bracket => ']'},
        ]},
      ],
    }
  end

  it "should parse an unavailable name" do
    @grammar.parse(%{<i>basalis</i>. <i>Forelius chalybaeus</i> st. <i>grandis</i> var. <i>basalis</i> Santschi, 1922b: 375 (w.q.m.) ARGENTINA. Unavailable name (Shattuck, 1994: 97); material referred to <i>grandis</i> by Cuezzo, 2000: 242.}).value_with_reference_text_removed
  end

  it "should parse an entry without forms that's a junior homonym" do
    @grammar.parse(%{*<i>transversa</i>. *<i>Fallomyrma transversa</i> Dlussky & Radchenko, 2006a: 156, figs. 1-6 UKRAINE (Rovno Amber). [Junior primary homonym of <i>Formica foetida</i> Linnaeus, 1758: 582 (now in <i>Pachycondyla</i>).] Replacement name: <i>mccooki</i> McCook, 1879: 187.}).value
  end

  it "should parse a subspecies" do
    @grammar.parse(%{<i>alpicola</i>. <i>Formica fusca</i> var. <i>alpicola</i> Gredler, 1858: 10 (w.) AUSTRIA. Relationship with <i>densiventris</i>: Cole, 1954a: 89.}).value_with_reference_text_removed.should == {
      :type => :species_record,
      :species_group_epithet => 'alpicola',
      :protonym => {
        :genus_name => 'Formica',
        :species_epithet => 'fusca',
        :subspecies => [{:type => 'var.', :subspecies_epithet => 'alpicola'}],
        :authorship => [{:author_names => ['Gredler'], :year => '1858', :pages => '10', :forms => 'w.'}],
        :locality => 'Austria',
      },
      :history => [
        {:relationship_with => {
          :species_epithet => 'densiventris',
          :references => [{:author_names => ['Cole'], :year => '1954a', :pages => '89'}]
        }}
      ]
    }
  end

  it "should parse one with multiple senior synonyms" do
    @grammar.parse(%{<i>pruinosus</i>. <i>Tapinoma pruinosum</i> Roger, 1863a: 165 (w.) CUBA. Wheeler, G.C. & Wheeler, J. 1951: 185 (l.). Combination in <i>Iridomyrmex</i>: Wheeler, W.M. 1913b: 497; in <i>Forelius</i>: Wheeler, G.C. & Wheeler, J. 1986g: 13; Shattuck, 1992c: 95. Senior synonym of <i>testaceus</i>: Cuezzo, 2000: 261; of <i>analis</i>: Ward, 2005: 9. See also: Creighton, 1950a: 342; Petralia & Vinson, 1980: 386; Guerrero & Fernández, 2008: 57.}).value
  end

  it "should parse an unresolved junior primary homonym" do
    @grammar.parse(%{<i>apicalis</i>. <i>Formica apicalis</i> Smith, F. 1858b: 49 (q.) "South America"; locality in error. [Unresolved junior primary homonym of <i>apicalis</i> Latreille, 1802c: 204, above.] Junior synonym of <i>rufa</i>: Roger, 1862c: 287.}).value
  end

  it "should parse an originally nomen nudum" do
    @grammar.parse(%{<i>attenuata</i>. <i>Formica attenuata</i> Schilling, 1830: 55. <i>Nomen nudum</i>.}).value
  end

  it "should handle when there's no space between two bracketed history items" do
    @grammar.parse(%{<i>ciliata</i>. <i>Formica pratensis</i> var. <i>ciliata</i> Ruzsky, 1926: 110 (w.q.) RUSSIA. [First available use of <i>Formica rufa</i> subsp. <i>pratensis</i> var. <i>ciliata</i> Ruzsky, 1915b: 7; unavailable name.][Unresolved junior primary homonym of <i>ciliata</i> Mayr, above.]}).value
  end

  it "should be able to parse this one with material of a nomen nudum referred here" do
    @grammar.parse(%{<i>cinerea</i>. <i>Formica cinerea</i> Mayr, 1853c: 281 (w.q.) AUSTRIA. Mayr, 1855: 344 (m.). Combination in <i>F. (Serviformica)</i>: Forel, 1915d: 64. Subspecies of <i>fusca</i>: Forel, 1874: 54; Emery & Forel, 1879: 451; Mayr, 1886d: 427; Forel, 1892i: 307; Emery, 1909b: 199; Bondroit, 1910: 483; Emery, 1914d: 159. Status as species: Mayr, 1861: 48; Emery, 1898c: 126; Ruzsky, 1902d: 12; Forel, 1904b: 385; Wheeler, W.M. 1913f: 521; Forel, 1915d: 64; Emery, 1916b: 255; Wheeler, W.M. 1917a: 550; Menozzi, 1918: 88; Bondroit, 1918: 53; Müller, 1923: 141; Emery, 1925b: 246; Karavaiev, 1929b: 214; Karavaiev, 1936: 224; Dlussky, 1967a: 65; Bernard, 1967: 300; Dlussky & Pisarski, 1971: 157; Pisarski, 1975: 42; Kutter, 1977c: 252; Collingwood, 1979: 124; Atanassov & Dlussky, 1992: 264. Senior synonym of <i>brevisetosa</i>: Finzi, 1928a: 68; of <i>subrufoides</i>: Agosti & Collingwood, 1987a: 59. Material of the <i>nomen nudum</i> <i>cinereoglebaria</i> referred here: Dlussky & Pisarski, 1971: 157. Senior synonym of <i>armenica</i>, <i>balcanica</i>, <i>iberica</i>, <i>imitans</i>, <i>italica</i>, <i>novaki</i>: Seifert, 2002b: 251. Current subspecies: nominal plus <i>cinereoimitans</i>.})
  end

  it "should handle this special punctuation of 'no caste given' plus a nomen nudum with material referred to" do
    @grammar.parse(%{<i>cinereoglebaria</i>. <i>Formica cinerea</i> var. <i>cinereoglebaria</i> Kulmatycki, 1922: 85, no caste given, POLAND. <i>Nomen nudum</i>; material referred to <i>cinerea</i> by Dlussky & Pisarski, 1971: 157.}).value
  end

  it "handle a missing period after the header" do
    @grammar.parse('<i>fuscescens</i> <i>Formica fuscescens</i> Gmelin, in Linnaeus, 1790: 2804 (w.) EUROPE. Unidentifiable to genus; <i>incertae sedis</i> in <i>Formica</i>: Bolton, 1995b: 195.').value
  end

  it "should handle the asterisk before the octothorpe" do
    @grammar.parse('*<i>major</i>. *<i>Formica lavateri</i> var. <i>major</i> Heer, 1867: 11, pl. 1, fig. 106 (q.) CROATIA (Miocene). [Unresolved junior primary homonym of <i>major</i> Nylander, 1849: 29, above.]').value
  end

  it "should handle an unresolved junior primary homonym before other forms" do
      @grammar.parse('<i>rubescens</i>. <i>Formica fusca</i> var. <i>rubescens</i> Forel, 1904f: 423 (w.) SWITZERLAND. [Unresolved junior primary homonym of <i>rubescens</i> Leach, above.] Emery, 1909b: 196 (q.); Wheeler, W.M. 1913f: 498 (m.). Subspecies of <i>glebaria</i>: Bondroit, 1918: 50; Boven, 1947: 188. Junior synonym of <i>cunicularia</i>: Yarrow, 1954a: 231; Dlussky, 1967a: 73; Bernard, 1967: 296; Seifert & Schultz, 2009: 261.').value
  end

  it "should handle a replacement name" do
    @grammar.parse('<i>sinae</i>. <i>Formica (Serviformica) rufibarbis</i> var. <i>sinae</i> Emery, 1925b: 250. Replacement name for <i>orientalis</i> Wheeler, W.M. 1923b: 4. [Junior primary homonym of <i>orientalis</i> Ruzsky, 1915a: 427.] Santschi, 1928b: 42 (q.). Junior synonym of <i>glauca</i>: Dlussky, 1967a: 74. Revived from synonymy and raised to species: Wu, 1990: 4. Subspecies of <i>clara</i>: Seifert & Schultz, 2009: 265.').value
  end

  it "should handle a homonym with a replacement name" do
    @grammar.parse '<i>foetida</i>. <i>Formica foetida</i> Buckley, 1866: 167 (w.q.) U.S.A. Crozier, 1970: 113 (k.); Wheeler, G.C. & Wheeler, J. 1974b: 401 (l.) [Junior primary homonym of <i>Formica foetida</i> Linnaeus, 1758: 582 (now in <i>Pachycondyla</i>).] Replacement name: <i>mccooki</i> McCook, 1879: 187.'
  end

  describe "parsing the unparseable" do
    it "should save unparseable sentences as notes" do
      @grammar.parse(%{<i>candida</i>. <i>Formica candida</i> Smith, F. 1878b: 11 (q.) KYRGHYZSTAN. [Smith's description is repeated by Bingham, 1903: 335 (footnote).] Probable synonym of <i>picea</i> Nylander: Emery, 1925b: 249. Junior synonym of <i>picea</i> Nylander: Dlussky, 1967a: 61. Hence <i>candida</i> first available replacement name for <i>Formica picea</i> Nylander, 1846a: 917 [Junior primary homonym of <i>Formica picea</i> Leach, 1825: 292 (now in <i>Camponotus</i>).]: Bolton, 1995b: 192. Valid species, not synonymous with <i>picea</i> Nylander: Seifert, 2004: 35. Current subspecies: nominal plus <i>formosae</i>.}).value_with_reference_text_removed.should == {
        :type => :species_record,
        :species_group_epithet => 'candida',
        :protonym => {
          :genus_name => 'Formica',
          :species_epithet => 'candida',
          :authorship => [{:author_names => ['Smith, F.'], :year => '1878b', :pages => '11', :forms => 'q.'}],
          :locality => 'Kyrghyzstan',
        },
        :history => [
          {:text => [
            {:opening_bracket => '['},
            {:phrase => "Smith's description is repeated by", :delimiter => ' '},
            {:author_names => ['Bingham'], :year => '1903', :pages => '335 (footnote)', :delimiter => '.'},
            {:closing_bracket => ']'},
          ]},
          {:synonym_ofs => [{
            :probable => true,
            :junior_or_senior => :junior,
            :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}],
            :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '249'}]
          }]},
          {:synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}],
            :references => [{:author_names => ['Dlussky'], :year => '1967a', :pages => '61'}]
          }]},
          {:text => [
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
                :delimiter => '.'
              },
              {:closing_bracket=>"]"}
            ], :delimiter=>": "},
            {:author_names=>["Bolton"], :year=>"1995b", :pages=>"192"},
          ], text_suffix: '. '},
          {:text => [
            {:phrase=>"Valid species, not synonymous with", :delimiter => " "},
            {:species_group_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}], :delimiter => ': '},
            {:author_names => ['Seifert'], :year => '2004', :pages => '35'},
          ], text_suffix: '. '},
          {:subspecies => [{:species_group_epithet => 'formosae'}]},
        ]
      }
    end
  end

  it "should handle a period after an unparseable" do
    @grammar.parse('<i>pediculus</i>. <i>Formica pediculus</i> Christ, 1791: 518 (w.) no locality given. [According to Emery, 1892b: 162, this is a termite, Order ISOPTERA].').value_with_reference_text_removed.should == {
      :type => :species_record,
      :species_group_epithet => 'pediculus',
      :protonym => {
        :genus_name => 'Formica',
        :species_epithet => 'pediculus',
        :authorship => [{:author_names => ['Christ'], :year => '1791', :pages => '518', :forms => 'w.'}],
        :locality => 'no locality given',
      },
      :history => [
        {:text => [
          {:opening_bracket => '['},
          {:phrase => 'According to', :delimiter => ' '},
          {:author_names => ['Emery'], :year => '1892b', :pages => '162'},
          {:phrase => ', this is a termite, Order ISOPTERA'},
          {:closing_bracket => ']'},
          {:delimiter => '.'},
        ]}
      ]
    }
  end

  it "should handle a parenthetical note after a reference" do
    @grammar.parse('<i>australis</i>. <i>Amblyopone australis</i> Erichson, 1842: 261, pl. 5, fig. 7 (w.) AUSTRALIA. Smith, F. 1858b: 109 (q.m.); Wheeler, G.C. & Wheeler, J. 1952a: 116 (l.); Imai, Crozier & Taylor, 1977: 347 (k.). Senior synonym of <i>laevidens</i>, <i>nana</i>: Wilson, 1958a: 142; of <i>cephalotes</i> (and its junior synonym <i>maculata</i>): Brown, 1958h: 14; of <i>fortis</i>, <i>foveolata</i>, <i>minor</i>, <i>obscura</i>, and material of the unavailable names <i>howensis</i>, <i>norfolkensis</i>, <i>pallens</i>, <i>queenslandica</i> referred here: Brown, 1960a: 167 (these previously provisional synonyms in Brown, 1958h: 13). See also: Taylor, 1979: 835.').value[:type].should == :species_record
  end

  it "handle a complicated 'forms'" do
    @grammar.parse("<i>humilis</i>. <i>Acanthomyrmex humilis</i> Eguchi, Bui & Yamane, 2008: 238, figs. 22-30 (s.w.ergatoid q.) VIETNAM.").value[:type].should == :species_record
  end

  it "should handle a senior synonym list where one of the clauses is unparseable" do
    @grammar.parse(%{*<i>flori</i>. *<i>Formica flori</i> Mayr, 1868c: 48, pl. 2, figs. 35-37 (w.q.m.) BALTIC AMBER (Eocene). Senior synonym of *<i>antiqua</i>, *<i>baltica</i>, *<i>parvula</i>: Dlussky, 2002a: 292; of *<i>egecomerta</i> (replacement name for *<i>parvula</i> Dlussky, proposed subsequent to Dlussky's 2002a synonymy and hence automatic junior synonym). See also: Dlussky, 1967b: 81; Baroni Urbani & Graeser, 1987: 1; Dlussky, 2008a: 50.}).value
  end

  it "should handle an abbreviated genus" do
    @grammar.parse(%{<i>occidentalis</i>. <i>Formica fusca</i> var. <i>occidentalis</i> Wheeler, W.M. 1908g: 409 (w.) U.S.A. <i>Nomen nudum</i>. <i>F. rufibarbis</i> var. <i>occidentalis</i> Wheeler, W.M. 1910g: 570. <i>Nomen nudum</i>. <i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90, unnecessary replacement name. <i>Nomen nudum</i>.}).value
  end

  it "should handle a period at the end of a bracket" do
    @grammar.parse(%{<i>stitzi</i>. <i>Formica rufa</i> subsp. <i>truncicola</i> ab. <i>stitzi</i> Krausse, 1926d: 264 (w.) GERMANY. Unavailable name. [<i>Formica truncorum</i> ab. <i>stitzi</i> Stitz, 1939: 347; unavailable name.]. Material referred to <i>truncorum</i> by Dlussky, 1967a: 81.}).value
  end

  #it "should parse a legitimate start, but with unparsed history" do
    #@grammar.parse(%{*<i>tucumanus</i>. *<i>Neoforelius tucumanus</i> var. <i>modesta</i> Kusnezov, 1953b: 330, figs. 1-12, no caste given, BALTIC AMBER (Eocene). Member of unresolved <i>pilosum</i>-complex: Lattke, 1997: 165. Current subspecies: nominal plus <i>formosae</i>.}).value_with_reference_text_removed.should == {
      #:type => :species_record,
      #:species_group_epithet => 'tucumanus',
      #:fossil => true,
      #:protonym => {
        #:genus_name => 'Neoforelius',
        #:species_epithet => 'tucumanus',
        #:subspecies => [{:type => 'var.', :subspecies_epithet => 'modesta'}],
        #:author_names => ['Kusnezov'], :year => '1953b', :pages => '330, figs. 1-12', :forms => 'no caste given',
        #:fossil => true,
        #:locality => 'Baltic Amber (Eocene)',
      #},
      #:history => [
        #{:text => [
          #{:phrase => "Member of unresolved", :delimiter => " "},
          #{:species_group_epithet => "pilosum"},
          #{:unparseable => '-complex: Lattke, 1997: 165'},
        #]},
        #{:subspecies => [{:species_group_epithet => 'formosae'}]},
      #]
    #}
  #end

  describe "Bad protonyms" do
    it "should parse weirdness in the protonym name" do
      @grammar.parse(%{<i>expolitus</i>. <i>Aphaenogaster (Attomyrmex</i> [sic]) <i>expolitus</i> Azuma, 1950: 34, JAPAN. <i>Nomen nudum</i>. See Onoyama, 1980: 194.}).value_with_reference_text_removed.should == {
        :type => :species_record,
        :species_group_epithet => 'expolitus',
        :unparseable => '<i>Aphaenogaster (Attomyrmex</i> [sic]) <i>expolitus</i> Azuma, 1950: 34, JAPAN. <i>Nomen nudum</i>. See Onoyama, 1980: 194.'
      }
    end
    it "should parse a missing protonym" do
      @grammar.parse(%{*<i>tucumanus</i>. Unknown.}).value_with_reference_text_removed.should == {
        :type => :species_record,
        :species_group_epithet => 'tucumanus',
        :fossil => true,
        :unparseable => 'Unknown.'
      }
    end
  end

  it "should consider a 'see reference' as a see-under" do
    @grammar.parse(%{<i>unifasciata</i> Bostock, 1838; see Bolton, 1987: 356.}).value
  end

  it "should handle no space after label's period" do
    @grammar.parse(%{*<i>vetula</i>.*<i>Nylanderia vetula</i> LaPolla & Dlussky, 2010: 263, fig. 3 (w.) DOMINICAN AMBER.}).value
  end

  # This fails with 'stack level too deep'
  #it "should handle a subspecies without a subspecies type" do
    #@grammar.parse('<i>nura</i>. <i>Crematogaster longispina</i> <i>nura</i> Ozdikmen, 2010c: 989.').value
  #end

end
