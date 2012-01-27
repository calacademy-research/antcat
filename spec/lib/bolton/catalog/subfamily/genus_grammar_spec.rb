# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Grammar do
  before do
    @grammar = Bolton::Catalog::Subfamily::Grammar
  end

  describe "Genera header" do
    describe "Genera header" do
      it "should be recognized" do
        @grammar.parse(%{Genera of Aneuretini}).value_with_reference_text_removed.should == {type: :genera_header}
      end
      it "should be recognized when there's only one genus" do
        @grammar.parse(%{Genus of Dolichoderini}).value_with_reference_text_removed.should == {type: :genera_header}
      end
      it "should be recognized when it's this one weird tribe name" do
        @grammar.parse(%{Genus of Platythyreini}, :root => :genera_header).value_with_reference_text_removed.should == {type: :genera_header}
      end
    end

    describe "Genera incertae sedis header" do
      it "should be recognized" do
        @grammar.parse(%{Genera <i>incertae sedis</i> in ANEURETINAE}).value_with_reference_text_removed.should == {type: :genera_incertae_sedis_header}
      end
      it "should be recognized when there's only one genus" do
        @grammar.parse(%{Genus <i>incertae sedis</i> in ANEURETINAE}).value_with_reference_text_removed.should == {type: :genera_incertae_sedis_header}
      end
      it "should be recognized when extinct" do
        @grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in DOLICHODERINAE}).value_with_reference_text_removed.should == {type: :genera_incertae_sedis_header}
      end
      it "should be recognized when Hong's" do
        @grammar.parse(%{Genera of Hong (2002), <i>incertae sedis</i> in FORMICINAE}).value_with_reference_text_removed.should == {type: :genera_of_hong_header}
      end
      it "should be recognized in poneroid subfamilies" do
        @grammar.parse('Genera <i>incertae sedis</i> in poneroid subfamilies').value_with_reference_text_removed.should == {
          type: :genera_incertae_sedis_in_poneroid_subfamilies_header
        }
      end
    end

  end

  describe "Genus headers" do
    describe "Genus header" do
      it "should recognize a genus header" do
        @grammar.parse(%{Genus <i>ATTA</i>}).value_with_reference_text_removed.should == {type: :genus_header, :name => 'Atta'}
      end
      it "should recognize the beginning of a fossil genus" do
        @grammar.parse(%{Genus *<i>ANEURETELLUS</i>}).value_with_reference_text_removed.should == {type: :genus_header, :name => 'Aneuretellus', :fossil => true}
      end

      it "should handle it when there's a subfamily at the end" do
        @grammar.parse(%{Genus *<i>YPRESIOMYRMA</i> [Myrmeciinae]}).value_with_reference_text_removed.should ==
          {type: :genus_header, :name => 'Ypresiomyrma', :fossil => true, :note => {:name => 'Myrmeciinae'}}
      end
    end

    describe "Genus nomen nudum header" do
      it "should handle it" do
        @grammar.parse(%{<i>ANCYLOGNATHUS</i> [<i>nomen nudum</i>]}).value_with_reference_text_removed.should == {type: :genus_nomen_nudum_header, :name => 'Ancylognathus'}
      end
      it "should handle a fossil nomen nudum header" do
        @grammar.parse(%{*<i>DOLICHOFORMICA</i> [<i>nomen nudum</i>]}).value_with_reference_text_removed.should ==
          {type: :genus_nomen_nudum_header, :name => 'Dolichoformica', :fossil => true}
      end
    end

  end

  describe "Genus record" do

    describe "Type species" do
      it "should handle a type-species by subsequent designation" do
        @grammar.parse('Type-species: <i>Bothriomyrmex myops</i>, by subsequent designation of Donisthorpe, 1944e: 102', :root => :type_species).value_with_reference_text_removed.should == {
          type_species: {
            :genus_name => 'Bothriomyrmex',
            :species_epithet => 'myops',
            :texts => [{:text => [
                {:phrase => ', by subsequent designation of', :delimiter => ' '},
                {:author_names => ['Donisthorpe'], :year => '1944e', :pages => '102'},
              ]}],
          }
        }
      end
      it "should handle a type-species that it doesn't understand" do
        @grammar.parse('Type-species: none subsequent', :root => :type_species).value_with_reference_text_removed.should == {
          type_species: {:texts => [{:text => [{:phrase => 'none subsequent'}]}]}
        }
      end
      it "should handle a type-species that's nomen nudum" do
        @grammar.parse('Type-species: <i>Ancylognathus lugubris</i>, <i>nomen nudum</i>.', :root => :type_species).value_with_reference_text_removed.should == {
          type_species: {
            :genus_name => 'Ancylognathus',
            :species_epithet => 'lugubris',
            :texts => [{:text => [
                {:phrase => ',', :delimiter => ' '},
                {:phrase => '<i>nomen nudum</i>'},
            ], text_suffix:'.'}]
          }
        }
      end
    end

    it "should handle a genus headline with a type species that's nomen nudum" do
      @grammar.parse('<i>Ancylognathus</i> Lund, 1831a: 121. Type-species: <i>Ancylognathus lugubris</i>, <i>nomen nudum</i>. [<i>Ancylognathus</i> material referred to <i>Eciton</i>: Smith, F. 1855c: 160.]', :root => :genus_headline).value
    end

    it "should recognize a genus headline" do
      @grammar.parse(%{<i>Odontomyrmex</i> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Odontomyrmex',
          :authorship => [{:author_names => ['André'], :year => '1905', :pages => '207'}],
        },
        type_species: {
          :genus_name => 'Odontomyrmex',
          :species_epithet => 'quadridentatus',
          :texts => [{:text => [{:phrase => ', by monotypy'}], :text_suffix => '.'}]
        }
      }
    end
    it "should handle a genus headline where the genus is nomen nudum as well as the type-species" do
      @grammar.parse('*<i>Dolichoformica</i> Grimaldi & Engel, 2005: 446 (in table), <i>nomen nudum</i>. Type-species: *<i>Dolichoformica helferi</i>, <i>nomen nudum</i>.').value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Dolichoformica',
          :fossil => true,
          :authorship => [{:author_names => ['Grimaldi', 'Engel'], :year => '2005', :pages => '446 (in table)'}],
        },
        :nomen_nudum => true,
        type_species: {
          :genus_name => 'Dolichoformica', :species_epithet => 'helferi', :fossil => true,
          :texts => [{:text => [
            {:phrase => ',', :delimiter => ' '},
            {:phrase=>'<i>nomen nudum</i>'}
          ], text_suffix:'.'}]
        }
      }
    end

    it "should recognize a genus headline with nomen nudum" do
      @grammar.parse(
%{*<i>Dolichoformica</i> Grimaldi & Engel, 2005: 446 (in table), <i>nomen nudum</i>.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Dolichoformica',
          :fossil => true,
          :authorship => [{:author_names => ['Grimaldi', 'Engel'], :year => '2005', :pages => '446 (in table)'}],
        },
        :nomen_nudum => true,
      }
    end
    it "should handle bracketed phrase after genus nomen nudum" do
      @grammar.parse(
%{<i>Myrmegis</i> Rafinesque, 1815: 124, <i>nomen nudum</i>. [Brown, 1973b: 182.]}
      ).value_with_reference_text_removed.should == {
        type: :genus_headline,
        protonym: {genus_name:"Myrmegis", authorship:[{author_names:["Rafinesque"], year:"1815", pages:"124"}]},
        :note => {:text=>[{:opening_bracket=>"["}, {:author_names=>["Brown"], :year=>"1973b", :pages=>"182", :delimiter=>"."}, {:closing_bracket=>"]"}]},
        nomen_nudum:true
      }
    end

    it "should recognize a fossil genus headline with a note" do
      @grammar.parse(%{*<i>Calyptites</i> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
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
        },
        type_species: {
          :genus_name => 'Calyptites', :species_epithet => 'antediluvianum', :fossil => true,
          :texts => [:text => [{:phrase => ', by monotypy'}], text_suffix:'.']
        }
      }
    end
    it "should recognize a subgenus" do
      @grammar.parse(%{<i>Hypochira</i> Buckley, 1866: 169 [as subgenus of <i>Formica</i>]. Type-species: <i>Formica (Hypochira) subspinosa</i>, by monotypy.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Hypochira',
          :authorship => [{
            :author_names => ['Buckley'], :year => '1866', :pages => '169',
            :notes => [[
              {:phrase => 'as subgenus of', :delimiter => ' '},
              {:genus_name => 'Formica'},
              {:bracketed => true},
            ]]
          }],
        },
        type_species: {
          :genus_name => 'Formica', :subgenus_epithet => 'Hypochira', :species_epithet => 'subspinosa',
          :texts => [:text => [{:phrase => ', by monotypy'}], text_suffix:'.']
        }
      }
    end
    it "should recognize a type-species that's a junior synonym" do
       @grammar.parse(%{*<i>Eoformica</i> Cockerell, 1921: 38. Type-species: *<i>Eoformica eocenica</i> (junior synonym of *<i>Eoformica pingue</i>), by monotypy.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Eoformica',
          :fossil => true,
          :authorship => [{:author_names => ['Cockerell'], :year => '1921', :pages => '38'}],
        },
        type_species: {
          :genus_name => 'Eoformica',
          :species_epithet => 'eocenica',
          :fossil => true,
          :texts => [
            {:text => [
              {:opening_parenthesis=>"("},
              {:phrase=>"junior synonym of", :delimiter=>" "},
              {:genus_name=>"Eoformica", :species_epithet=>"pingue", :fossil=>true},
              {:closing_parenthesis=>")"}
            ], text_prefix:' '},
            {:text => [{:phrase=>", by monotypy"}], text_suffix:'.'},
          ],
        }
      }
    end
    it "should recognize a type-species by original designation" do
      @grammar.parse(%{*<i>Gerontoformica</i> Nel & Perrault, in Nel, Perrault, Perrichot & Néraudeau, 2004: 24. Type-species: *<i>Gerontoformica cretacica</i>, by original designation.}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Gerontoformica',
          :fossil => true,
          :authorship => [{
              :author_names => ['Nel', 'Perrault'],
              :in => {:author_names => ['Nel', 'Perrault', 'Perrichot', 'Néraudeau'], :year => '2004'},
              :pages => '24'
          }],
        },
        type_species: {
          :genus_name => 'Gerontoformica',
          :species_epithet => 'cretacica',
          :fossil => true,
          :texts => [{:text => [{:phrase=>", by original designation"}], text_suffix:'.'}],
        }
      }
    end
    it "should recognize the 'genus headline' that actually describes a collective group name" do
      @grammar.parse(%{*<i>Myrmeciites</i> Archibald, Cover & Moreau, 2006: 500. [Collective group name.]}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Myrmeciites',
          :fossil => true,
          :authorship => [{:author_names => ['Archibald', 'Cover', 'Moreau'], :year => '2006', :pages => '500'}],
        },
        :collective_group_name => true,
      }
    end
    it "should recognize an unnecessary replacement name" do
      @grammar.parse(%{<i>Baroniurbania</i> Pagliano & Scaramozzino, 1990: 4. Unnecessary replacement name for <i>Acantholepis</i> Mayr (junior homonym).}).value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Baroniurbania',
          :authorship => [{:author_names => ['Pagliano', 'Scaramozzino'], :year => '1990', :pages => '4'}],
        },
        :unnecessary_replacement_name_for => {:genus_name => 'Acantholepis', :authorship => [:author_names => ['Mayr']]}, :junior_homonym => true
      }
    end
    it "should recognize an unnecessary replacement name for sensu name" do
      @grammar.parse('<i>Parasima</i> Donisthorpe, 1948d: 592 [as subgenus of <i>Tetraponera</i>]. [Unnecessary replacement name for <i>Sima</i> in the sense of Emery, 1921f: 23.]').value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Parasima',
          :authorship => [{:author_names => ['Donisthorpe'], :year => '1948d', :pages => '592',
            :notes => [[
              {:phrase => 'as subgenus of', :delimiter => ' '},
              {:genus_name => 'Tetraponera'},
              {:bracketed => true},
            ]]}],
        },
        :unnecessary_replacement_name_for => {:genus_name => 'Sima', :sensu => {:author_names => ['Emery'], :year => '1921f', :pages => '23'}}
      }
    end
    it "should recognize an unjustified emendation" do
      @grammar.parse('<i>Ceratopachys</i> Schulz, W.A. 1906: 155, unjustified emendation of <i>Cerapachys</i>.').value_with_reference_text_removed.should == {
        type: :genus_headline,
        :protonym => {
          :genus_name => 'Ceratopachys',
          :authorship => [{:author_names => ['Schulz, W.A.'], :year => '1906', :pages => '155'}],
        },
        :unjustified_emendation_of => {:genus_name => 'Cerapachys'}
      }
    end
    it "should recognize a subsequent unjustified emendation" do
      @grammar.parse('<i>Vollenhovenia</i> Dalla Torre, 1893: 61, unjustified subsequent emendation of <i>Vollenhovia</i>.').value_with_reference_text_removed.should == {
        :type => :genus_headline,
        :protonym => {
          :genus_name => 'Vollenhovenia',
          :authorship => [{:author_names => ['Dalla Torre'], :year => '1893', :pages => '61'}],
        },
        :unjustified_emendation_of => {:genus_name => 'Vollenhovia'},
        :subsequent => true
      }
    end
  end

  describe "Homonym replaced by genus header" do
    it "should be recognized" do
      @grammar.parse(%{Homonym replaced by *<i>PROMYRMICIUM</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header, title: 'Homonym replaced by *<i>PROMYRMICIUM</i>'}
    end
    it "should be recognized" do
      @grammar.parse(%{Homonym replaced by <i>STIGMACROS</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header, title: 'Homonym replaced by <i>STIGMACROS</i>'}
    end
    it "should be recognized as :other when a homonym-replaced-by in a synonym" do
      @grammar.parse(%{Homonym replaced by <i>Karawajewella</i>}).value_with_reference_text_removed.should == {:type => :homonym_replaced_by_genus_header, title: 'Homonym replaced by <i>Karawajewella</i>'}
    end
  end

  describe "Junior synonym headers" do
    it "should recognize a header for the group of synonyms" do
      @grammar.parse(%{Junior synonyms of <i>ANEURETUS</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header, title: 'Junior synonyms of <i>ANEURETUS</i>'}
    end
    it "should recognize a header for the group of synonyms when there's only one" do
      @grammar.parse(%{Junior synonym of <i>ANEURETUS</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header, title: 'Junior synonym of <i>ANEURETUS</i>'}
    end
    it "should recognize a header for the group of synonyms when there's a period after the closing tags" do
      @grammar.parse(%{Junior synonyms of <i>ACROPYGA</i>.}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header, title: 'Junior synonyms of <i>ACROPYGA</i>.'}
    end
    it "should be recognized when they are of a fossil" do
      @grammar.parse(%{Junior synonyms of *<i>ARCHIMYRMEX</i>}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_genus_header, title: 'Junior synonyms of *<i>ARCHIMYRMEX</i>'}
    end
  end

  describe "Genus references header" do
    it "should handle a regular header" do
      @grammar.parse(%{Genus <i>Sphinctomyrmex</i> references}).value_with_reference_text_removed.should == {type: :genus_references_header, genus_name: 'Sphinctomyrmex', title: 'Genus <i>Sphinctomyrmex</i> references'}
    end
    it "should handle a header without a name" do
      @grammar.parse(%{Genus references}).value_with_reference_text_removed.should == {type: :genus_references_header, title: 'Genus references'}
    end
    it "should handle a 'see above' header" do
      @grammar.parse(%{Genus <i>Myrmoteras</i> references: see above.}).value_with_reference_text_removed.should == {type: :genus_references_see_under, title: 'Genus <i>Myrmoteras</i> references: see above.'}
    end
    it "should handle a 'see above' header without the genus name" do
      @grammar.parse(%{Genus references: see above.}).value_with_reference_text_removed.should == {type: :genus_references_see_under, title: 'Genus references: see above.'}
    end
    it "should handle a 'see above' header without the genus name" do
      @grammar.parse(%{Genus references: see under Aneuretini, above.}).value_with_reference_text_removed.should == {
        type: :genus_references_see_under,
        title: 'Genus references: see under Aneuretini, above.'
      }
    end
  end

end
