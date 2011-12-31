# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Grammar do
  before do
    @grammar = Bolton::Catalog::Subfamily::Grammar
  end

  describe "Genera header" do
    describe "Genera header" do
      it "should be recognized" do
        @grammar.parse(%{Genera of Aneuretini}).value_with_reference_text_removed.should == {:type => :genera_header}
      end
      it "should be recognized when there's only one genus" do
        @grammar.parse(%{Genus of Dolichoderini}).value_with_reference_text_removed.should == {:type => :genera_header}
      end
      it "should be recognized when it's this one weird tribe name" do
        @grammar.parse(%{Genus of Platythyreini}, :root => :genera_header).value_with_reference_text_removed.should == {:type => :genera_header}
      end
    end

    describe "Genera incertae sedis header" do
      it "should be recognized" do
        @grammar.parse(%{Genera <i>incertae sedis</i> in ANEURETINAE}).value_with_reference_text_removed.should == {:type => :genera_incertae_sedis_header}
      end
      it "should be recognized when there's only one genus" do
        @grammar.parse(%{Genus <i>incertae sedis</i> in ANEURETINAE}).value_with_reference_text_removed.should == {:type => :genera_incertae_sedis_header}
      end
      it "should be recognized when extinct" do
        @grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in DOLICHODERINAE}).value_with_reference_text_removed.should == {:type => :genera_incertae_sedis_header}
      end
      it "should be recognized when Hong's" do
        @grammar.parse(%{Genera of Hong (2002), <i>incertae sedis</i> in FORMICINAE}).value_with_reference_text_removed.should == {:type => :genera_of_hong_header}
      end
      it "should be recognized in poneroid subfamilies" do
        @grammar.parse('Genera <i>incertae sedis</i> in poneroid subfamilies').value_with_reference_text_removed.should == {
          :type => :genera_incertae_sedis_in_poneroid_subfamilies_header
        }
      end
    end

  end

  describe "Genus headers" do
    describe "Genus header" do
      it "should recognize a genus header" do
        @grammar.parse(%{Genus <i>ATTA</i>}).value_with_reference_text_removed.should == {:type => :genus_header, :name => 'Atta'}
      end
      it "should recognize the beginning of a fossil genus" do
        @grammar.parse(%{Genus *<i>ANEURETELLUS</i>}).value_with_reference_text_removed.should == {:type => :genus_header, :name => 'Aneuretellus', :fossil => true}
      end

      it "should handle it when there's a subfamily at the end" do
        @grammar.parse(%{Genus *<i>YPRESIOMYRMA</i> [Myrmeciinae]}).value_with_reference_text_removed.should ==
          {:type => :genus_header, :name => 'Ypresiomyrma', :fossil => true, :note => {:name => 'Myrmeciinae'}}
      end
    end

    describe "Genus nomen nudum header" do
      it "should handle it" do
        @grammar.parse(%{<i>ANCYLOGNATHUS</i> [<i>nomen nudum</i>]}).value_with_reference_text_removed.should == {:type => :genus_nomen_nudum_header, :name => 'Ancylognathus'}
      end
      it "should handle a fossil nomen nudum header" do
        @grammar.parse(%{*<i>DOLICHOFORMICA</i> [<i>nomen nudum</i>]}).value_with_reference_text_removed.should ==
          {:type => :genus_nomen_nudum_header, :name => 'Dolichoformica', :fossil => true}
      end
    end

  end

  describe "Genus record" do
    describe "Type species" do
      it "should handle a type-species by subsequent designation" do
        @grammar.parse('Type-species: <i>Bothriomyrmex myops</i>, by subsequent designation of Donisthorpe, 1944e: 102.', :root => :type_species).value_with_reference_text_removed.should == {
          :type_species => {
            :genus_name => 'Bothriomyrmex', :species_epithet => 'myops', :by => :subsequent_designation,
            :author_names => ['Donisthorpe'], :year => '1944e', :pages => '102'
          }
        }
      end
      it "should handle a type-species that it doesn't understand" do
        @grammar.parse('Type-species: none subsequent', :root => :type_species).value_with_reference_text_removed.should == {
          :type_species => {:text => [{:phrase => 'none subsequent'}]}
        }
      end

      it "should handle a type-species that's nomen nudum" do
        @grammar.parse('Type-species: <i>Ancylognathus lugubris</i>, <i>nomen nudum</i>.', :root => :type_species).value
      end
    end

    it "should handle a genus headline with a type species that's nomen nudum" do
      @grammar.parse('<i>Ancylognathus</i> Lund, 1831a: 121. Type-species: <i>Ancylognathus lugubris</i>, <i>nomen nudum</i>. [<i>Ancylognathus</i> material referred to <i>Eciton</i>: Smith, F. 1855c: 160.]', :root => :genus_headline).value
    end

    it "should recognize a genus headline" do
      @grammar.parse(%{<i>Odontomyrmex</i> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Odontomyrmex',
        :authorship => [{:author_names => ['André'], :year => '1905', :pages => '207'}],
        :type_species => {
          :genus_name => 'Odontomyrmex', :species_epithet => 'quadridentatus', :by => :monotypy
        }
      }
    end
    it "should handle a genus headline where the genus is nomen nudum as well as the type-species" do
      @grammar.parse('*<i>Dolichoformica</i> Grimaldi & Engel, 2005: 446 (in table), <i>nomen nudum</i>. Type-species: *<i>Dolichoformica helferi</i>, <i>nomen nudum</i>.').value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Dolichoformica',
        :fossil => true,
        :authorship => [{:author_names => ['Grimaldi', 'Engel'], :year => '2005', :pages => '446 (in table)'}],
        :nomen_nudum => true,
        :type_species => {
          :genus_name => 'Dolichoformica', :species_epithet => 'helferi', :fossil => true, :nomen_nudum => true
        }
      }
    end

    it "should recognize a genus headline with nomen nudum" do
      @grammar.parse(
%{*<i>Dolichoformica</i> Grimaldi & Engel, 2005: 446 (in table), <i>nomen nudum</i>.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Dolichoformica',
        :authorship => [{:author_names => ['Grimaldi', 'Engel'], :year => '2005', :pages => '446 (in table)'}],
        :nomen_nudum => true,
        :fossil => true
      }
    end
    it "should handle bracketed phrase after genus nomen nudum" do
      @grammar.parse('<i>Myrmegis</i> Rafinesque, 1815: 124, <i>nomen nudum</i>. [Brown, 1973b: 182, places <i>Myrmegis</i> as a junior synonym of <i>Atta</i>, because the entry in Rafinesque reads, "6. <i>Myrmegis</i> R. <i>Atta</i> Latr."]').value_with_reference_text_removed
    end

    it "should recognize a fossil genus headline with a note" do
      @grammar.parse(%{*<i>Calyptites</i> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Calyptites',
        :fossil => true,
        :authorship => [{
          :author_names => ['Scudder'], :year => '1877b', :pages => '270',
          :notes => [[
            {:phrase => 'as member of family', :delimiter => ' '},
            {:family_or_subfamily_name => 'Braconidae'},
            {:bracketed => true}
          ]]
         }],
        :type_species => {
          :genus_name => 'Calyptites', :species_epithet => 'antediluvianum', :fossil => true,
          :by => :monotypy
        }
      }
    end
    it "should recognize a subgenus" do
      @grammar.parse(%{<i>Hypochira</i> Buckley, 1866: 169 [as subgenus of <i>Formica</i>]. Type-species: <i>Formica (Hypochira) subspinosa</i>, by monotypy.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Hypochira',
        :authorship => [{
          :author_names => ['Buckley'], :year => '1866', :pages => '169',
          :notes => [[
            {:phrase => 'as subgenus of', :delimiter => ' '},
            {:genus_name => 'Formica'},
            {:bracketed => true},
          ]]
        }],
        :type_species => {
          :genus_name => 'Formica', :subgenus_epithet => 'Hypochira', :species_epithet => 'subspinosa',
          :by => :monotypy
        }
      }
    end
    it "should recognize a type-species that's a junior synonym" do
      @grammar.parse(%{*<i>Eoformica</i> Cockerell, 1921: 38. Type-species: *<i>Eoformica eocenica</i> (junior synonym of *<i>Eoformica pingue</i>), by monotypy.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Eoformica',
        :fossil => true,
        :authorship => [{:author_names => ['Cockerell'], :year => '1921', :pages => '38'}],
        :type_species => {
          :genus_name => 'Eoformica', :species_epithet => 'eocenica', :fossil => true,
          :junior_synonym_of => {
            :genus_name => 'Eoformica', :species_epithet => 'pingue', :fossil => true
          },
          :by => :monotypy
        }
      }
    end
    it "should recognize a type-species by original designation" do
      @grammar.parse(%{*<i>Gerontoformica</i> Nel & Perrault, in Nel, Perrault, Perrichot & Néraudeau, 2004: 24. Type-species: *<i>Gerontoformica cretacica</i>, by original designation.}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Gerontoformica',
        :fossil => true,
        :authorship => [{:author_names => ['Nel', 'Perrault'],
        :in => {
          :author_names => ['Nel', 'Perrault', 'Perrichot', 'Néraudeau'], :year => '2004'
        },
        :pages => '24'}],
        :type_species => {
          :genus_name => 'Gerontoformica', :species_epithet => 'cretacica', :fossil => true,
          :by => :original_designation
        }
      }
    end
    it "should recognize the 'genus headline' that actually describes a collective group name" do
      @grammar.parse(%{*<i>Myrmeciites</i> Archibald, Cover & Moreau, 2006: 500. [Collective group name.]}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Myrmeciites',
        :fossil => true,
        :collective_group_name => true,
        :authorship => [{:author_names => ['Archibald', 'Cover', 'Moreau'], :year => '2006', :pages => '500'}],
      }
    end
    it "should recognize an unnecessary replacement name" do
      @grammar.parse(%{<i>Baroniurbania</i> Pagliano & Scaramozzino, 1990: 4. Unnecessary replacement name for <i>Acantholepis</i> Mayr (junior homonym).}).value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Baroniurbania',
        :authorship => [{:author_names => ['Pagliano', 'Scaramozzino'], :year => '1990', :pages => '4'}],
        :unnecessary_replacement_name_for => {:genus_name => 'Acantholepis', :authorship => [:author_names => ['Mayr']]}, :junior_homonym => true
      }
    end
    it "should recognize an unnecessary replacement name for sensu name" do
      @grammar.parse('<i>Parasima</i> Donisthorpe, 1948d: 592 [as subgenus of <i>Tetraponera</i>]. [Unnecessary replacement name for <i>Sima</i> in the sense of Emery, 1921f: 23.]').value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Parasima',
        :authorship => [{:author_names => ['Donisthorpe'], :year => '1948d', :pages => '592',
          :notes => [[
            {:phrase => 'as subgenus of', :delimiter => ' '},
            {:genus_name => 'Tetraponera'},
            {:bracketed => true},
          ]]}],
        :unnecessary_replacement_name_for => {:genus_name => 'Sima', :sensu => {:author_names => ['Emery'], :year => '1921f', :pages => '23'}}
      }
    end
    it "should recognize an unjustified emendation" do
      @grammar.parse('<i>Ceratopachys</i> Schulz, W.A. 1906: 155, unjustified emendation of <i>Cerapachys</i>.').value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Ceratopachys',
        :authorship => [{:author_names => ['Schulz, W.A.'], :year => '1906', :pages => '155'}],
        :unjustified_emendation_of => {:genus_name => 'Cerapachys'}
      }
    end
    it "should recognize a subsequent unjustified emendation" do
      @grammar.parse('<i>Vollenhovenia</i> Dalla Torre, 1893: 61, unjustified subsequent emendation of <i>Vollenhovia</i>.').value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :genus_name => 'Vollenhovenia',
        :authorship => [{:author_names => ['Dalla Torre'], :year => '1893', :pages => '61'}],
        :unjustified_emendation_of => {:genus_name => 'Vollenhovia'},
        :subsequent => true
      }
    end
  end

  describe "Homonym replaced by genus header" do
    it "should be recognized" do
      @grammar.parse(%{Homonym replaced by *<i>PROMYRMICIUM</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header}
    end
    it "should be recognized" do
      @grammar.parse(%{Homonym replaced by <i>STIGMACROS</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header}
    end
    it "should be recognized as :other when a homonym-replaced-by in a synonym" do
      @grammar.parse(%{Homonym replaced by <i>Karawajewella</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header}
    end
  end

  describe "Junior synonym headers" do
    it "should recognize a header for the group of synonyms" do
      @grammar.parse(%{Junior synonyms of <i>ANEURETUS</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header}
    end
    it "should recognize a header for the group of synonyms when there's only one" do
      @grammar.parse(%{Junior synonym of <i>ANEURETUS</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header}
    end
    it "should recognize a header for the group of synonyms when there's a period after the closing tags" do
      @grammar.parse(%{Junior synonyms of <i>ACROPYGA</i>.}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header}
    end
    it "should be recognized when they are of a fossil" do
      @grammar.parse(%{Junior synonyms of *<i>ARCHIMYRMEX</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header}
    end
  end

  describe "Genus references header" do
    it "should handle a regular header" do
      @grammar.parse(%{Genus <i>Sphinctomyrmex</i> references}).value_with_reference_text_removed.should == {:type => :genus_references_header}
    end
    it "should handle a header without a name" do
      @grammar.parse(%{Genus references}).value_with_reference_text_removed.should == {:type => :genus_references_header}
    end
    it "should handle a 'see above' header" do
      @grammar.parse(%{Genus <i>Myrmoteras</i> references: see above.}).value_with_reference_text_removed.should == {:type => :genus_references_see_under}
    end
    it "should handle a 'see above' header without the genus name" do
      @grammar.parse(%{Genus references: see above.}).value_with_reference_text_removed.should == {:type => :genus_references_see_under}
    end
    it "should handle a 'see above' header without the genus name" do
      @grammar.parse(%{Genus references: see under Aneuretini, above.}).value_with_reference_text_removed.should == {
        :type => :genus_references_see_under,
        :see_under => {:tribe_name => 'Aneuretini'}
      }
    end
  end

  describe "Taxonomic history items" do
    describe "anything we can't otherwise deal with, for now" do
      it "should parse a bracketed phrase as text" do
        @grammar.parse(%{[Type-species not <i>Tapinoma instabilis</i>]}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :text => [
             {:opening_bracket => '['},
             {:phrase => 'Type-species not', :delimiter => ' '},
             {:genus_name => 'Tapinoma', :species_epithet => 'instabilis'},
             {:closing_bracket => ']'},
            ]
          }
      end
    end

    it "should handle this one that looks like a headerline" do
      @grammar.parse('*<i>Ponerites</i> Dlussky, 1981b: 67 [collective group name].', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
        :type => :genus_taxonomic_history_item,
        :collective_group_name => 'Ponerites',
        :references => [{:author_names => ['Dlussky'], :year => '1981b', :pages => '67'}],
      }
    end

    describe "'in family'" do
      it "should parse 'in family'" do
        @grammar.parse(%{<i>Condylodon</i> in family Mutillidae: Swainson & Shuckard, 1840: 173.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Condylodon'},
           :in => [{:taxon => [:family_or_subfamily_name => 'Mutillidae']}],
           :references => [{:author_names => ['Swainson', 'Shuckard'], :year => '1840', :pages => '173'}],
          }
      end

      it "should parse 'in <family>, <subfamily>" do
        @grammar.parse('*<i>Promyrmicium</i> in Formicidae, Myrmicinae: Baroni Urbani, 1971b: 362; Bolton, 1994: 106 (anachronism).', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Promyrmicium', :fossil => true},
          :in => [{:taxon => [
            {:family_or_subfamily_name => 'Formicidae'},
            {:family_or_subfamily_name => 'Myrmicinae'}
          ]}],
          :references => [
             {:author_names => ['Baroni Urbani'], :year => '1971b', :pages => '362'},
             {:author_names => ['Bolton'], :year => '1994', :pages => '106', :notes => [[{:phrase => 'anachronism'}]]},
          ]
        }
      end

      it "should parse 'as subgenus of" do
        @grammar.parse('<i>Chronoxenus</i> as subgenus of <i>Bothriomyrmex</i>: Santschi, 1919i: 202.', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Chronoxenus'},
          :as_subgenus_of => {:genus => {:genus_name => 'Bothriomyrmex'}},
          :references => [{:author_names => ['Santschi'], :year => '1919i', :pages => '202'}]
        }
      end

      it "should parse 'in <subfamily>, <tribe>, <subtribe>" do
        @grammar.parse('<i>Arnoldius</i> in Dolichoderinae, Iridomyrmecini, Bothriomyrmecina: Dubovikov, 2005a: 93.', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Arnoldius'},
          :in => [{:taxon => [
            {:family_or_subfamily_name => 'Dolichoderinae'},
            {:tribe_name => 'Iridomyrmecini'},
            {:subtribe_name => 'Bothriomyrmecina'}
          ]}],
          :references => [{:author_names => ['Dubovikov'], :year => '2005a', :pages => '93'}]
        }
      end

      it "should parse a tribe with an order-looking prefix" do
        @grammar.parse('<i>Noonilla</i> in Leptanillinae, Leptanillini: Bolton, 1990b: 276.', :root => :genus_taxonomic_history_item).value
      end

      it "should parse 'in subfamily, fossil tribe'" do
        @grammar.parse('*<i>Pityomyrmex</i> in Dolichoderinae, *Pityomyrmecini: Wheeler, W.M. 1915h: 98.', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Pityomyrmex', :fossil => true},
          :in => [{:taxon => [
            {:family_or_subfamily_name => 'Dolichoderinae'},
            {:tribe_name => 'Pityomyrmecini', :fossil => true}
          ]}],
          :references => [{:author_names => ['Wheeler, W.M.'], :year => '1915h', :pages => '98'}]
        }
      end

      it "should parse special case of Myrmiciidae (Symphyta)" do
        @grammar.parse(%{*<i>Myrmicium</i> in *Myrmiciidae (Symphyta): Maa, 1949: 17; Rasnitsyn, 1969: 17; Jarzembowski, 1993: 179.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Myrmicium', :fossil => true},
           :in => [{:taxon => [{:family_name => 'Myrmiciidae', :fossil => true, :suborder => 'Symphyta'}]}],
           :references => [
              {:author_names => ['Maa'], :year => '1949', :pages => '17'},
              {:author_names => ['Rasnitsyn'], :year => '1969', :pages => '17'},
              {:author_names => ['Jarzembowski'], :year => '1993', :pages => '179'},
            ],
          }
      end
      it "should parse 'in family?'" do
        @grammar.parse(%{<i>Condylodon</i> in family Mutillidae?: Swainson & Shuckard, 1840: 173.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Condylodon'},
           :in => [{:taxon => [:family_or_subfamily_name => 'Mutillidae'], :questionable => true}],
           :references => [{:author_names => ['Swainson', 'Shuckard'], :year => '1840', :pages => '173'}],
          }
      end
      it "should handle a fossil, and more than one reference" do
        @grammar.parse(%{*<i>Calyptites</i> in Braconidae: Scudder, 1891: 629; Donisthorpe, 1943f: 629.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Calyptites', :fossil => true},
           :in => [{:taxon => [:family_or_subfamily_name => 'Braconidae']}],
           :references => [
             {:author_names => ['Scudder'], :year => '1891', :pages => '629'},
             {:author_names => ['Donisthorpe'], :year => '1943f', :pages => '629'}
           ],
          }
      end
      it "should parse 'in family, tribe'" do
        @grammar.parse(%{*<i>Eoformica</i> in Formicinae, Oecophyllini: Donisthorpe, 1943f: 643.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Eoformica', :fossil => true},
           :in => [{:taxon => [{:family_or_subfamily_name => 'Formicinae'}, {:tribe_name => 'Oecophyllini'}]}],
           :references => [
             {:author_names => ['Donisthorpe'], :year => '1943f', :pages => '643'}
           ],
          }
      end
      describe "'dubiously'" do
        it "should parse 'not in family, dubiously family'" do
          @grammar.parse(%{<i>Condylodon</i> not in Pseudomyrmecinae, dubiously Ponerinae: Ward, 1990: 471.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
            :type => :genus_taxonomic_history_item,
            :genus => {:genus_name => "Condylodon"},
            :in => [
              {:taxon => [:family_or_subfamily_name => 'Pseudomyrmecinae'], :not => true},
              {:taxon => [:family_or_subfamily_name => 'Ponerinae'], :dubious => true}
            ],
            :references => [
              {:author_names => ['Ward'], :year => '1990', :pages => '471'},
            ]}
        end
        it "should parse 'dubiously family'" do
          @grammar.parse(%{*<i>Cretacoformica</i> dubiously Formicidae: Bolton, 1995b: 25, 166.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
            :type => :genus_taxonomic_history_item,
            :genus => {:genus_name => "Cretacoformica", :fossil => true},
            :in => [
              {:taxon => [:family_or_subfamily_name => 'Formicidae'], :dubious => true},
            ],
            :references => [
              {:author_names => ['Bolton'], :year => '1995b', :pages => '25, 166'},
            ]}
        end
        it "should parse 'dubiously in subfamily'" do
          @grammar.parse(%{*<i>Burmomyrma</i> dubiously in Aneuretinae: Dlussky, 1996: 87.}, :root => :genus_taxonomic_history_item).value[:type].should == :genus_taxonomic_history_item
        end

      end

      it "should parse 'in <order>" do
        @grammar.parse(%{*<i>Palaeomyrmex</i> in Homoptera: Handlirsch, 1906: 507.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => "Palaeomyrmex", :fossil => true},
          :in => [{:taxon => [:order_name => 'Homoptera']}],
          :references => [{:author_names => ['Handlirsch'], :year => '1906', :pages => '507'}],
        }
      end

      it "should handle bracketed note at end" do
        @grammar.parse(%{<i>Bothriomyrmex</i> in Formicinae: André, 1881b: 64 [Formicidae].}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => "Bothriomyrmex"},
          :in => [{:taxon => [:family_or_subfamily_name => 'Formicinae']}],
          :references => [{
            :author_names => ['André'], :year => '1881b', :pages => '64',
            :text => [
              {:opening_bracket => '['},
              {:family_or_subfamily_name => 'Formicidae'},
              {:closing_bracket => ']'},
            ]
          }]
        }
      end

    end

    describe "'incertae sedis in'" do
      it "should parse 'incertae sedis in family' (with parenthetical note)" do
        @grammar.parse(%{*<i>Calyptites</i> <i>incertae sedis</i> in Formicidae: Carpenter, 1930: 21; Brown, 1973b: 179; Bolton, 1995b: 23, 83 (family unresolved).}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => "Calyptites", :fossil => true},
          :incertae_sedis_in => [{:family_name => 'Formicidae'}],
          :references => [
            {:author_names => ['Carpenter'], :year => '1930', :pages => '21'},
            {:author_names => ['Brown'], :year => '1973b', :pages => '179'},
            {:author_names => ['Bolton'], :year => '1995b', :pages => '23, 83',
              :notes => [[{:phrase => 'family unresolved'}]],
            },
          ],
        }
      end
      it "should parse 'incertae sedis in order, order'" do
        @grammar.parse(%{*<i>Cariridris</i> <i>incertae sedis</i> in Hymenoptera, Aculeata: Grimaldi, Agosti & Carpenter, 1997: 7.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => "Cariridris", :fossil => true},
          :incertae_sedis_in => [{:order_name => 'Hymenoptera'}, {:order_name => 'Aculeata'}],
          :references => [
            {:author_names => ['Grimaldi', 'Agosti', 'Carpenter'], :year => '1997', :pages => '7'},
          ],
        }
      end
    end

    describe "'also described as new'" do
      it "should handle this" do
        @grammar.parse('[<i>Aneuretus</i> also described as new by Emery, 1893f: 241.]', :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => "Aneuretus"},
          :also_described_as_new => true,
          :bracketed => true,
          :references => [{:author_names => ['Emery'], :year => '1893f', :pages => '241'}]
        }
      end
    end

    describe "nomina nuda" do
      it "should handle it" do
        @grammar.parse("[*<i>Paraneuretus</i> Wheeler, W.M. 1908g: 413; <i>nomina nuda</i>.]", :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {
            :genus_name => "Paraneuretus", :fossil => true,
            :authorship => [{:author_names => ['Wheeler, W.M.'], :year => '1908g', :pages => '413'}]
          },
          :bracketed => true,
          :nomina_nuda => true
        }
      end
    end

    describe "'junior synonym of'" do
      it "should parse 'junior synonym of'" do
        @grammar.parse(%{<i>Condylodon</i> as junior synonym of <i>Pseudomyrma</i>: Dalla Torre, 1893: 55.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Condylodon'},
           :as_junior_synonym_of => {:genus => {:genus_name => 'Pseudomyrma'}},
           :references => [{:author_names => ['Dalla Torre'], :year => '1893', :pages => '55'}],
          }
      end
      it "should parse 'as questionable junior synonym of'" do
        @grammar.parse(%{<i>Hypochira</i> as questionable junior synonym of <i>Dolichoderus</i>: Emery, 1895c: 338; Emery, 1925b: 271.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :genus_taxonomic_history_item,
           :genus => {:genus_name => 'Hypochira'},
           :as_junior_synonym_of => {:genus => {:genus_name => 'Dolichoderus'}, :questionable => true},
           :references => [
             {:author_names => ['Emery'], :year => '1895c', :pages => '338'},
             {:author_names => ['Emery'], :year => '1925b', :pages => '271'},
            ],
          }
      end
    end

    it "should parse 'excluded from family'" do
      @grammar.parse(%{*<i>Cretacoformica</i> excluded from Formicidae: Naumann, 1993: 355.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Cretacoformica', :fossil => true},
          :excluded_from => {:family_name => 'Formicidae'},
          :references => [{:author_names => ['Naumann'], :year => '1993', :pages => '355'}],
        }
    end

    it "should parse 'as genus'" do
      @grammar.parse(%{*<i>Myrmicium</i> as genus: Westwood, 1854: 396.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Myrmicium', :fossil => true},
          :as_genus => true,
          :references => [{:author_names => ['Westwood'], :year => '1854', :pages => '396'}],
        }
    end

    describe "Incorrect subsequent spelling" do
      it "should handle an incorrect subsequent spelling" do
        @grammar.parse(%{*<i>Myrmicium</i> in Myrmicinae: Dalla Torre, 1893: 108 (as *<i>Myrmecium</i>, incorrect subsequent spelling); Bolton, 1995b: 37 (anachronism).}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Myrmicium', :fossil => true},
          :in => [{:taxon => [:family_or_subfamily_name => 'Myrmicinae']}],
          :references => [
            {:author_names => ['Dalla Torre'], :year => '1893', :pages => '108',
              :notes => [[
                {:phrase => "as", :delimiter => ' '},
                {:genus_name => 'Myrmecium', :fossil => true},
                {:phrase => ', incorrect subsequent spelling'},
              ]]
            },
            {:author_names => ['Bolton'], :year => '1995b', :pages => '37',
              :notes => [[{:phrase => 'anachronism'}]]
            }
          ],
        }
      end
      it "should handle another form of incorrect subsequent spelling" do
        @grammar.parse(%{<i>Bregmatomyrmex</i> [incorrect subsequent spelling] <i>incertae sedis</i> in Formicidae: Wheeler, G.C. & Wheeler, J. 1985: 259.}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Bregmatomyrmex'},
          :incertae_sedis_in => {:family_name => 'Formicidae', :incorrect_subsequent_spelling => true},
          :references => [{:author_names => ['Wheeler, G.C.', 'Wheeler, J.'], :year => '1985', :pages => '259'}],
        }
      end
    end

    describe "Bracketed items" do
      it "should handle the bracketed 'replacement name for' note" do
        @grammar.parse(%{[Replacement name for *<i>Myrmicium</i> Heer, 1870: 78; junior homonym of *<i>Myrmicium</i> Westwood, 1854: 396.]}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :replacement_name_for => {
            :genus => {:genus_name => 'Myrmicium', :fossil => true, :authorship => [{:author_names => ['Heer'], :year => '1870', :pages => '78'}]},
            :junior_homonym_of => {:genus_name => 'Myrmicium', :fossil => true, :authorship => [{:author_names => ['Westwood'], :year => '1854', :pages => '396'}]},
          }
        }
      end
      it "should handle the bracketed 'junior homonym of' note" do
        @grammar.parse(%{[Junior homonym of *<i>Myrmicium</i> Westwood, 1854: 396 (*Pseudosiricidae).]}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :junior_homonym_of => {
            :genus_name => 'Myrmicium', :fossil => true,
            :authorship => [{:author_names => ['Westwood'], :year => '1854', :pages => '396',
              :notes => [[{:family_or_subfamily_name => 'Pseudosiricidae', :fossil => true}]]}]
          }
        }
      end
      it "A genus name, and then a class name in parentheses" do
        @grammar.parse(%{[<i>Diabolus</i> Karavaiev junior homonym of <i>Diabolus</i> Gray, J.E. 1841: 400 (Mammalia).]}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :genus => {:genus_name => 'Diabolus',
                     :authorship => [{:author_names => ['Karavaiev']}]},
          :junior_homonym_of => {
            :genus_name => 'Diabolus',
            :authorship => [{
              :author_names => ['Gray, J.E.'], :year => '1841', :pages => '400',
                             :notes => [[{:order_name => 'Mammalia'}]]}]
          }
        }
      end
      it "should handle the bracketed item about Formicites" do
        @grammar.parse(%{[*<i>Formicites</i> (collective group name) material absorbed into *<i>Eoformica</i>: Dlussky & Rasnitsyn, 2002: 424.]}, :root => :genus_taxonomic_history_item).value_with_reference_text_removed.should == {
          :type => :genus_taxonomic_history_item,
          :material_absorbed => {
            :from => {
              :collective_group_name => 'Formicites',
              :fossil => true,
            },
            :to => {:genus_name => 'Eoformica', :fossil => true}
          },
          :references => [{:author_names => ['Dlussky', 'Rasnitsyn'], :year => '2002', :pages => '424'}]
        }
      end
    end

  end

end
