# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Species::DeepSpeciesGrammar do
  before do
    @grammar = Bolton::Catalog::Species::DeepSpeciesGrammar
  end

  describe "parsing notes" do
    it "should parse a note" do
      @grammar.parse('[Note. ]').value_with_reference_text_removed.should == {:type => :note, :text => '[Note. ]'}
    end
  end

  describe "History items" do
    it "should parse redescription of type-material" do
      @grammar.parse('Type-material redescribed: Crawley, 1922c: 19', :root => :history_item).value_with_reference_text_removed.should == {
        :type_material_redescribed => {:references => [{:author_names => ['Crawley'], :year => '1922c', :pages => '19'}]}}
    end

    it "should handle a history item with <recte>" do
      @grammar.parse('Type-series referred to <i>testaceipes</i>-group (<i>recte</i> <i>terebrans</i>-group): McArthur & Adams, 1996: 41.', :root => :history_item).value_with_reference_text_removed.should == {
        :text => [
          {:phrase => "Type-series referred to", :delimiter=>" "},
          {:species_group_epithet=>"testaceipes"},
          {:phrase=>"-group", :delimiter=>" "},
          {:text=>[
            {:opening_parenthesis=>"("},
            {:phrase=>"<i>recte</i>", :delimiter=>" "},
            {:species_group_epithet=>"terebrans"},
            {:phrase=>"-group"},
            {:closing_parenthesis=>")"}
          ], :delimiter=>": "},
          {:author_names=>["McArthur", "Adams"], :year=>"1996", :pages=>"41"}
        ]
      }
    end

    describe "Homonyms" do
      it "should parse a replacement name" do
        @grammar.parse('Replacement name for <i>crinita</i> Wheeler, W.M., above. [Junior primary homonym of <i>Formica foetida</i> Linnaeus, 1758: 582.]', :root => :history_item).value_with_reference_text_removed.should == {
          :replacement_for => {
            :species_epithet => 'crinita',
            :authorship => [{:author_names => ['Wheeler, W.M.']}],
            :homonym_of => {
              :primary_or_secondary => :primary,
              :genus_name => 'Formica',
              :species_epithet => 'foetida',
              :authorship => [{:author_names => ['Linnaeus'], :year => '1758', :pages => '582'}]
            }
          }
        }
      end
      it "should parse a junior primary homonym with a replacement name" do
        @grammar.parse('[Junior primary homonym of <i>alpina</i> Wheeler, above.] Replacement name: <i>mccooki</i> McCook, 1879: 187', :root => :history_item).value_with_reference_text_removed.should == {
          :homonym_of => {
            :primary_or_secondary => :primary,
            :species_epithet => 'alpina',
            :authorship => [{:author_names => ['Wheeler']}],
            :replacement => {
              :species_epithet => 'mccooki',
              :authorship => [{:author_names => ['McCook'], :year => '1879', :pages => '187'}]
            }
          }
        }
      end
      describe "Unresolved homonyms" do
        it "should parse an unresolved homonym" do
          @grammar.parse(%{Unresolved junior primary homonym of <i>apicalis</i> Latreille, 1802c: 204, above}, :root => :history_item).value_with_reference_text_removed.should ==
            {:homonym_of => {
              :primary_or_secondary => :primary,
              :unresolved => true,
              :species_epithet => 'apicalis',
              :authorship => [{:author_names => ['Latreille'], :year => '1802c', :pages => '204'}]
            }
          }
        end
        it "should parse an unresolved homonym without brackets" do
          @grammar.parse('Unresolved junior primary homonym of *<i>robusta</i> Carpenter, above', :root => :unresolved_homonym)
        end
      end
    end

    it "should parse 'also described as new'" do
      @grammar.parse('[Also described as new by Heer, 1850: 142.]', :root => :history_item).value_with_reference_text_removed.should == {
        :also_described_as_new => {
          :references => [{:author_names => ['Heer'], :year => '1850', :pages => '142'}]
        }
      }
    end

    describe "First available use of" do
      it "should parse first available use of" do
        @grammar.parse('First available use of <i>Forelius maccooki</i> r. <i>fiebrigi</i> var. <i>breviscapa</i> Forel, 1913l: 241; unavailable name',
                      :root => :history_item).value_with_reference_text_removed.should == {
          :first_available_use_of => {
            :genus_name => 'Forelius',
            :species_epithet => 'maccooki',
            :subspecies => [{:type => 'r.', :subspecies_epithet => 'fiebrigi'}, {:type => 'var.', :subspecies_epithet => 'breviscapa'}],
            :authorship => [{:author_names => ['Forel'], :year => '1913l', :pages => '241'}]
          }
        }
      end

      it "should work when the unavailable use doesn't mention 'unavailable name'" do
        @grammar.parse('First available use of <i>Formica fusca</i> r. <i>picea</i> var. <i>formosae</i> Forel, 1913f: 200',
                       :root => :history_item)
      end
      it "should parse first available use of when that phrase does not appear" do
        @grammar.parse('<i>Forelius maccooki</i> r. <i>fiebrigi</i> var. <i>breviscapa</i> Forel, 1913l: 241; unavailable name',
                      :root => :history_item).value_with_reference_text_removed[:first_available_use_of].should_not be_nil
      end
      it "should parse first available use of with a form" do
        @grammar.parse('<i>Forelius maccooki</i> r. <i>fiebrigi</i> var. <i>breviscapa</i> Forel, 1913l: 241 (w.); unavailable name',
                      :root => :history_item).value_with_reference_text_removed[:first_available_use_of].should_not be_nil
      end
    end

    describe "Nomen nudum" do
      it "should parse a nomen nudum" do
        @grammar.parse('<i>Nomen nudum</i>', :root => :history_item).value_with_reference_text_removed.should == {:nomen_nudum => {}}
      end
      it "should parse a nomen nudum with attribution" do
        @grammar.parse('<i>Nomen nudum</i>, attributed to Burmeister', :root => :history_item).value_with_reference_text_removed.should == {:nomen_nudum => {:attributed_to => 'Burmeister'}}
      end
    end

    it "should parse references as history items" do
      @grammar.parse('Mayr, 1886d: 432 (q.m.); Forel, 1886b: xxxix (w.)',
                    :root => :history_item).value_with_reference_text_removed.should == {
        :references => [
          {:author_names => ['Mayr'], :year => '1886d', :pages => '432', :forms => 'q.m.'},
          {:author_names => ['Forel'], :year => '1886b', :pages => 'xxxix', :forms => 'w.'},
        ]
      }
    end
    it "should parse first available replacement for a species epithet" do
      @grammar.parse('First available replacement name for <i>picea</i> Nylander: Donisthorpe, 1918a: 9',
                    :root => :history_item).value_with_reference_text_removed.should == {
        :first_available_replacement_for => {
          :species_epithet => 'picea',
          :authorship => [{:author_names => ['Nylander']}],
          :references => [{:author_names => ['Donisthorpe'], :year => '1918a', :pages => '9'}]
        }
      }
    end
    it "should parse first available replacement for a species name" do
      @grammar.parse('First available replacement name for <i>Formica picea</i> Nylander: Donisthorpe, 1918a: 9',
                    :root => :history_item).value_with_reference_text_removed.should == {
        :first_available_replacement_for => {
          :genus_name => 'Formica',
          :species_epithet => 'picea',
          :authorship => [{:author_names => ['Nylander']}],
          :references => [{:author_names => ['Donisthorpe'], :year => '1918a', :pages => '9'}]
        }
      }
    end
    it "should handle being part of another clause" do
      @grammar.parse('and hence first available replacement name for <i>picea</i> Nylander: Donisthorpe, 1918a: 9', :root => :history_item)
    end
    it "should parse nomina nuda being referred here 'by'" do
      @grammar.parse("Material of the <i>nomen nudum</i> <i>lucidula</i> referred here by Donisthorpe, 1915d: 83",
                     :root => :history_item).value_with_reference_text_removed.should == {
        :nomen_nudum_material_referred_here => {
          :species_group_epithet => 'lucidula',
          :references => [{:author_names => ['Donisthorpe'], :year => '1915d', :pages => '83'}]
        }
      }
    end
    it "should parse nomen nudum material referred here, with colon" do
      @grammar.parse(%{Material of the <i>nomen nudum</i> <i>cinereoglebaria</i> referred here: Dlussky & Pisarski, 1971: 157},
                     :root => :history_item).value_with_reference_text_removed.should == {
        :nomen_nudum_material_referred_here => {
          :species_group_epithet => 'cinereoglebaria',
          :references => [{:author_names => ['Dlussky', 'Pisarski'], :year => '1971', :pages => '157'}]
        }
      }
    end

    describe "material referred here" do
      it "should parse material of unavailable names referred here" do
        @grammar.parse(%{Material of the unavailable names <i>transversa</i>, <i>clara</i> referred here by Dlussky, 1967a: 77},
                      :root => :history_item).value_with_reference_text_removed.should == {
          :material_of_unavailable_names_referred_here => {
            :taxa => [{:species_group_epithet => 'transversa'}, {:species_group_epithet => 'clara'}],
            :references => [{:author_names => ['Dlussky'], :year => '1967a', :pages => '77'}]
          }
        }
      end
      it "should parse material of unavailable names referred here" do
        @grammar.parse(%{Material of the unavailable names <i>transversa</i>, <i>clara</i> referred here by Dlussky, 1967a: 77},
                      :root => :history_item).value_with_reference_text_removed.should == {
          :material_of_unavailable_names_referred_here => {
            :taxa => [{:species_group_epithet => 'transversa'}, {:species_group_epithet => 'clara'}],
            :references => [{:author_names => ['Dlussky'], :year => '1967a', :pages => '77'}]
          }
        }
      end
      it "should parse material of one unavailable name referred here" do
        @grammar.parse('Material of the unavailable name <i>pullula</i> referred here: Creighton, 1950a: 509',
                      :root => :history_item).value_with_reference_text_removed.should == {
          :material_of_unavailable_names_referred_here => {
            :taxa => [{:species_group_epithet => 'pullula'}],
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '509'}]
          }
        }
      end
    end

    describe "Raised to species" do
      it "should parse raised to species and material of unavailable name referred here" do
        @grammar.parse(%{Raised to species and material of the unavailable name <i>transversa</i> referred here by Dlussky, 1967a: 77},
                      :root => :history_item).value_with_reference_text_removed.should == {
          :raised_to_species => {
            :material_of_unavailable_names_referred_here => [{:species_group_epithet => 'transversa'}],
            :references => [{:author_names => ['Dlussky'], :year => '1967a', :pages => '77'}]
          }
        }
      end
      it "should parse raised to species and material of unavailable name referred here when it's not 'by' someone" do
        @grammar.parse(%{Raised to species and material of the unavailable name <i>transversa</i> referred here: Dlussky, 1967a: 77},
                      :root => :history_item)
      end
      it "should parse being raised to species" do
        @grammar.parse('Raised to species: Bolton & Fisher, 2000: 257',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :raised_to_species => {
            :references => [{:author_names => ['Bolton', 'Fisher'], :year => '2000', :pages => '257'}]
          }
        }
      end
      it "should parse being raised to species and senior synonym of" do
        @grammar.parse('Raised to species and senior synonym of <i>tucumanus</i>: Bolton & Fisher, 2000: 257',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :raised_to_species => {
            :references => [{:author_names => ['Bolton', 'Fisher'], :year => '2000', :pages => '257'}],
            :senior_synonym_of => {:species_epithet => 'tucumanus'}
          }
        }
      end
      it "should parse being revived to species and senior synonym of" do
        @grammar.parse('Revived status as species and senior synonym of <i>vetula</i>: Creighton, 1950a: 457',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_status_as_species => {
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '457'}],
            :junior_synonyms => [{:species_group_epithet => 'vetula'}],
          }
        }
      end
      it "should parse being revived from synonymy and raised to species" do
        @grammar.parse('Revived from synonymy and raised to species: Kusnezov, 1957b: 16 (in key)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :raised_to_species => {
            :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
            :revived_from_synonymy => true
          }
        }
      end
      it "should parse being revived from synonymy, raised to species, and senior synonym" do
        @grammar.parse('Revived from synonymy and raised to species: Kusnezov, 1957b: 16 (in key)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :raised_to_species => {
            :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
            :revived_from_synonymy => true
          }
        }
      end
    end

    describe "Revived from synonymy" do
      it "should parse being revived from synonymy, raised to species, and also a senior synonym" do
        @grammar.parse('Revived from synonymy, raised to species and senior synonym of <i>lecontei</i>: Francoeur, 1973: 172',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :senior_synonym_of => {:species_epithet => 'lecontei'},
            :raised_to_species => true,
            :references => [{:author_names => ['Francoeur'], :year => '1973', :pages => '172'}],
          }
        }
      end
      it "should parse revived from synonymy and senior synonym" do
        @grammar.parse('Revived from synonymy and senior synonym of <i>sublucida</i>: Buren, 1968a: 28',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :senior_synonym_of => {:species_epithet => 'sublucida'},
            :references => [{:author_names => ['Buren'], :year => '1968a', :pages => '28'}],
          }
        }
      end
      it "should parse being revived from synonymy" do
        @grammar.parse('Revived from synonymy: Kusnezov, 1957b: 16 (in key)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
          }
        }
      end
      it "should parse being revived from synonymy with status as species" do
        @grammar.parse('Revived from synonymy, with status as species: Dlussky, 1965a: 28',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :status_as_species => true,
            :references => [{:author_names => ['Dlussky'], :year => '1965a', :pages => '28'}]
          }
        }
      end
      it "should parse being revived from synonymy and status as species" do
        @grammar.parse('Revived from synonymy and status as species: Kusnezov, 1957b: 16 (in key)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :status_as_species => true,
            :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
          }
        }
      end
      it "should parse being revived from synonymy as subspecies of" do
        @grammar.parse('Revived from synonymy as subspecies of <i>fusca</i>: Kusnezov, 1957b: 16 (in key)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_from_synonymy => {
            :subspecies_of => {:species_epithet => 'fusca'},
            :references => [{:author_names => ['Kusnezov'], :year => '1957b', :pages => '16 (in key)'}],
          }
        }
      end
    end

    describe "Revived status as species" do
      it "should parse revived status as species" do
        @grammar.parse('Revived status as species: Bernard, 1967: 298',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_status_as_species => {
            :references => [{:author_names => ['Bernard'], :year => '1967', :pages => '298'}]
          }
        }
      end
      it "should parse revived status as species and senior synonym of" do
        @grammar.parse('Revived status as species and senior synonym of <i>goesswaldi</i>, <i>naefi</i>, <i>tamarae</i>: Seifert, 2000a: 543',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :revived_status_as_species => {
            :junior_synonyms => [{:species_group_epithet => 'goesswaldi'}, {:species_group_epithet => 'naefi'}, {:species_group_epithet => 'tamarae'}],
            :references => [{:author_names => ['Seifert'], :year => '2000a', :pages => '543'}]
          }
        }
      end
    end

    describe "unavailable names" do
      it "should parse an unavailable name" do
        @grammar.parse('Unavailable name (Shattuck, 1994: 97); material referred to <i>grandis</i> by Cuezzo, 2000: 242',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {
            :references => [{:author_names => ['Shattuck'], :year => '1994', :pages => '97'}],
            :material_referred_to => {
              :species_epithet => 'grandis',
              :references => [{:author_names=> ['Cuezzo'], :year => '2000', :pages => '242'}],
        }}}
      end
      it "should parse an unavailable name with material referred to a taxon with authorship" do
        @grammar.parse('Unavailable name (Shattuck, 1994: 97); material referred to <i>grandis</i> Forel (above) by Cuezzo, 2000: 242',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {
            :references => [{:author_names => ['Shattuck'], :year => '1994', :pages => '97'}],
            :material_referred_to => {
              :species_epithet => 'grandis', :authorship => [{:author_names => ['Forel']}],
              :references => [{:author_names=> ['Cuezzo'], :year => '2000', :pages => '242'}],
        }}}
      end
      it "should parse an unavailable name published as junior synonym" do
        @grammar.parse('Unavailable name (published as junior synonym; Bolton, 1995b: 190)',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {
            :references => [{:author_names => ['Bolton'], :year => '1995b', :pages => '190'}],
            :published_as_junior_synonym => true
        }}
      end
      it "should handle an unavailable name without parenthetical phrase" do
        @grammar.parse('Unavailable name; material referred to <i>rufa</i> by Yarrow, 1955a: 4',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {
            :material_referred_to => {
              :species_epithet => 'rufa',
              :references => [{:author_names=> ['Yarrow'], :year => '1955a', :pages => '4'}],
        }}}
      end
      it "should handle an unavailable name without a reference" do
        @grammar.parse('Unavailable name', :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {}
        }
      end
      it "should handle an unavailable name with just a reference" do
        @grammar.parse('Unavailable name (Bolton, 1995b: 193)', :root => :history_item).value_with_reference_text_removed.should == {
          :unavailable_name => {
            :references => [{:author_names=> ['Bolton'], :year => '1995b', :pages => '193'}],
          }
        }
      end
    end

    describe "junior synonym ofs" do
      it "should handle 'Provisional'" do
        @grammar.parse('Provisional junior synonym of <i>picea</i> Nylander: Emery, 1925b: 249',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}],
            :provisional => true,
            :junior_or_senior => :junior,
            :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '249'}]
          }]
        }
      end
      it "should handle 'probable'" do
        @grammar.parse('Probable synonym of <i>picea</i> Nylander: Emery, 1925b: 249',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}],
            :probable => true,
            :junior_or_senior => :junior,
            :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '249'}]
          }]
        }
      end
      it "should handle 'possible'" do
        @grammar.parse('Possible junior synonym of <i>picea</i> Nylander: Emery, 1925b: 249',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :species_epithet => 'picea', :authorship => [{:author_names => ['Nylander']}],
            :possible => true,
            :junior_or_senior => :junior,
            :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '249'}]
          }]
        }
      end
      it "should work with it doesn't say 'junior'" do
        @grammar.parse('Synonym of <i>subnuda</i>: Creighton, 1950a: 469',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :species_epithet => 'subnuda',
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '469'}]
          }]
        }
      end
      it "should parse a junior synonym clause" do
        @grammar.parse('Junior synonym of <i>nigriventris</i> Forel: Bolton & Fisher, 2000: 257',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'nigriventris', :authorship => [{:author_names => ['Forel']}],
            :references => [{:author_names => ['Bolton', 'Fisher'], :year => '2000', :pages => '257'}]
          }]
        }
      end
      it "should parse a multiple junior synonym clause" do
        @grammar.parse('Junior synonym of <i>nigriventris</i>: Bolton & Fisher, 2000: 257; of <i>mccooki</i>: Wheeler, 2002: 6',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'nigriventris',
            :references => [{:author_names => ['Bolton', 'Fisher'], :year => '2000', :pages => '257'}]
          },{
            :junior_or_senior => :junior,
            :species_epithet => 'mccooki',
            :references => [{:author_names => ['Wheeler'], :year => '2002', :pages => '6'}]
          }]
        }
      end
      it "should parse a fossil junior synonym clause without bothering about the fossil status" do
        @grammar.parse('Junior synonym of *<i>nigriventris</i>: Bolton & Fisher, 2000: 257',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'nigriventris',
            :fossil => true,
            :references => [{:author_names => ['Bolton', 'Fisher'], :year => '2000', :pages => '257'}]
          }]
        }
      end
      it "should handle a junior synonym that's an available replacement name" do
        @grammar.parse('Junior synonym of <i>foetida</i> Buckley: Wheeler, W.M. 1901b: 520 and hence first available replacement name for <i>Formica foetida</i> Buckley, 1866: 167. [Junior primary homonym of <i>Formica foetida</i> Linnaeus, 1758: 582.]',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :synonym_ofs => [{
            :junior_or_senior => :junior,
            :species_epithet => 'foetida', :authorship => [{:author_names => ['Buckley']}],
            :references => [{:author_names => ['Wheeler, W.M.'], :year => '1901b', :pages => '520'}],
            :replacement_for => {
              :genus_name => 'Formica',
              :species_epithet => 'foetida',
              :authorship => [{:author_names => ['Buckley'], :year => '1866', :pages => '167'}],
              :homonym_of => {
                :primary_or_secondary => :primary,
                :genus_name => 'Formica',
                :species_epithet => 'foetida',
                :authorship => [{:author_names => ['Linnaeus'], :year => '1758', :pages => '582'}]
              }
            }
          }]
        }
      end

    end

    it "should parse 'relationship with'" do
      @grammar.parse('Relationship with <i>densiventris</i>: Cole, 1954a: 89',
                     :root => :history_item).value_with_reference_text_removed.should == {
        :relationship_with => {
          :species_epithet => 'densiventris',
          :references => [{:author_names => ['Cole'], :year => '1954a', :pages => '89'}]
        }
      }
    end

    describe "senior synonym of" do
      it "should parse a very simple one" do
        @grammar.parse('Senior synonym of <i>obscurata</i>: Cuezzo, 2000: 235',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [{:species_epithet => 'obscurata'}],
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '235'}]
          }]
        }
      end
      it "should parse" do
        @grammar.parse('Senior synonym of <i>obscurata</i>, <i>instabilis</i>: Cuezzo, 2000: 235',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [{:species_epithet => 'obscurata'}, {:species_epithet => 'instabilis'}],
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '235'}]
          }]
        }
      end
      it "should handle a junior synonym with an authorship" do
        @grammar.parse('Senior synonym of <i>wheeleri</i> Stitz: Cuezzo, 2000: 235',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [{:species_epithet => 'wheeleri', :authorship => [{:author_names => ['Stitz']}]}],
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '235'}]
          }]
        }
      end
      it "should handle 'senior synonym of x (and its junior synonyms y, z)" do
        @grammar.parse('Senior synonym of <i>glauca</i> (and its junior synonyms <i>caucasica</i>, <i>katuniensis</i>, <i>montivaga</i>): Atanassov & Dlussky, 1992: 267',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [{
                :species_epithet => 'glauca',
                :junior_synonyms => [{:species_epithet => 'caucasica'}, {:species_epithet => 'katuniensis'}, {:species_epithet => 'montivaga'}],
              }],
            :references => [{:author_names => ['Atanassov', 'Dlussky'], :year => '1992', :pages => '267'}]}]
        }
      end
      it "should handle 'senior synonym of x (and its junior synonym y)" do
        @grammar.parse('Senior synonym of <i>glauca</i> (and its junior synonym <i>caucasica</i>): Atanassov & Dlussky, 1992: 267',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [{
              :species_epithet => 'glauca',
              :junior_synonyms => [{:species_epithet => 'caucasica'}]
            }],
            :references => [{:author_names => ['Atanassov', 'Dlussky'], :year => '1992', :pages => '267'}]}]
          }
      end

      it "should handle senior synonym with material being referred here" do
        @grammar.parse(
"Senior synonym of <i>fiebrigi</i>, <i>pilipes</i> and material of the unavailable name <i>carmelitana</i> referred here: Cuezzo, 2000: 229",
          :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [
              {:species_epithet => 'fiebrigi'},
              {:species_epithet => 'pilipes'}
            ],
            :material_of_unavailable_names_referred_here => [{:species_group_epithet => 'carmelitana'}],
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '229'}]
          }]
        }
      end
      it "should handle senior synonym with material from multiple unavailable names referred here" do
        @grammar.parse('Senior synonym of <i>bipilosa</i> and material of the unavailable names <i>clara</i>, <i>fallax</i> referred here: Dlussky, 1965a: 28',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [{
            :junior_synonyms => [
              {:species_epithet => 'bipilosa'},
            ],
            :material_of_unavailable_names_referred_here => [{:species_group_epithet => 'clara'}, {:species_group_epithet => 'fallax'}],
            :references => [{:author_names => ['Dlussky'], :year => '1965a', :pages => '28'}]
          }]
        }
      end
      it "should handle senior synonym with material from multiple unavailable names referred here with reference note" do
        @grammar.parse('Senior synonym of <i>laevidens</i>, <i>nana</i>: Wilson, 1958a: 142; of <i>cephalotes</i> (and its junior synonym <i>maculata</i>): Brown, 1958h: 14; of <i>fortis</i>, <i>foveolata</i>, <i>minor</i>, <i>obscura</i>, and material of the unavailable names <i>howensis</i>, <i>norfolkensis</i>, <i>pallens</i>, <i>queenslandica</i> referred here: Brown, 1960a: 167 (these previously provisional synonyms in Brown, 1958h: 13)', :root => :history_item).value_with_reference_text_removed[:senior_synonym_ofs].should_not be_nil
      end

      it "should handle multiple senior synonym ofs" do
        @grammar.parse(
"Senior synonym of <i>testaceus</i>: Cuezzo, 2000: 261; of <i>analis</i>: Ward, 2005: 9",
          :root => :history_item).value_with_reference_text_removed.should == {
          :senior_synonym_ofs => [
            { :junior_synonyms => [
                {:species_epithet => 'testaceus'},
              ],
              :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '261'}]
            },
            { :junior_synonyms => [
                {:species_epithet => 'analis'},
              ],
              :references => [{:author_names => ['Ward'], :year => '2005', :pages => '9'}]
            },
          ]
        }
      end
    end

    describe "combinations in" do
      it "should parse a 'combination in' clause" do
        @grammar.parse('Combination in <i>Forelius</i>: Shattuck, 1992c: 95',
                       :root => :history_item).value_with_reference_text_removed.should == {:combinations_in => [
          {:genus_name => 'Forelius',
           :references => [{:author_names => ['Shattuck'], :year => '1992c', :pages => '95'}]
          }
        ]}
      end
      it "should parse a 'combination in' clause with subgenus" do
        @grammar.parse('Combination in <i>Formica (Proformica)</i>: Wheeler, W.M. 1913f: 539',
                       :root => :history_item).value_with_reference_text_removed.should == {:combinations_in => [
          {:genus_name => 'Formica', :subgenus_epithet => 'Proformica',
           :references => [{:author_names => ['Wheeler, W.M.'], :year => '1913f', :pages => '539'}]
          }
        ]}
      end
      it "should parse a multiple 'combination in' clause" do
        @grammar.parse('Combination in <i>Forelius</i>: Shattuck, 1992c: 95; in <i>Atta</i>: Wheeler, G.C. 1986g: 13',
                       :root => :history_item).value_with_reference_text_removed.should == {:combinations_in => [
          {:genus_name => 'Forelius',
           :references => [{:author_names => ['Shattuck'], :year => '1992c', :pages => '95'}]},
          {:genus_name => 'Atta',
           :references => [{:author_names => ['Wheeler, G.C.'], :year => '1986g', :pages => '13'}]},
        ]}
      end
      it "should parse a fossil 'combination in' clause but not bother about returning it" do
        @grammar.parse('Combination in *<i>Forelius</i>: Shattuck, 1992c: 95',
                       :root => :history_item).value_with_reference_text_removed.should == {:combinations_in => [{
          :genus_name => 'Forelius',
          :fossil => true,
          :references => [{:author_names => ['Shattuck'], :year => '1992c', :pages => '95'}]
        }]}
      end
    end
    
    describe "Subspecies ofs" do
      it "should parse a 'subspecies of' clause" do
        @grammar.parse('Subspecies of <i>neorufibarbis</i> Forel: Creighton, 1950a: 537',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :subspecies_ofs => [{
            :species => {:species_epithet => 'neorufibarbis', :authorship => [{:author_names => ['Forel']}]},
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '537'}]
          }]
        }
      end
      it "should parse multiple 'subspecies of' clauses" do
        @grammar.parse('Subspecies of <i>neorufibarbis</i>: Creighton, 1950a: 537; of <i>rufa</i>: Walker, 1999: 100',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :subspecies_ofs => [
            {:species => {:species_epithet => 'neorufibarbis'}, :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '537'}]},
            {:species => {:species_epithet => 'rufa'}, :references => [{:author_names => ['Walker'], :year => '1999', :pages => '100'}]},
          ]
        }
      end
      it "should parse a fossil 'subspecies of' clause" do
        @grammar.parse('Subspecies of *<i>neorufibarbis</i>: Creighton, 1950a: 537',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :subspecies_ofs => [{
            :species => {:species_epithet => 'neorufibarbis', :fossil => true},
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '537'}]
          }]
        }
      end
      it "should parse a subspecies_of clause with 'material referred to'" do
        @grammar.parse('Subspecies of <i>whymperi</i> and material of the unavailable name <i>hybrida</i> referred here: Creighton, 1950a: 510',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :subspecies_ofs => [{
            :species => {:species_epithet => 'whymperi'},
            :material_referred_here => {:species_group_epithet => 'hybrida', :unavailable => true},
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '510'}]
          }]
        }
      end
    end

    describe "Currently subspecies of" do
      it "parse currently subspecies of" do
        @grammar.parse('Currently subspecies of <i>obscuriventris</i>: Creighton, 1950a: 494.',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :currently_subspecies_of => {
            :species => {:species_epithet => 'obscuriventris'},
            :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '494'}]
          }
        }
      end
    end

    describe "status as species" do
      it "should parse a 'status as species'" do
        @grammar.parse('Status as species: Creighton, 1950a: 537',
                       :root => :history_item).value_with_reference_text_removed.should == {:status_as_species => {
          :references => [{:author_names => ['Creighton'], :year => '1950a', :pages => '537'}]
        }}
      end
    end

    describe "Material referred to" do
      it "should parse 'material referred to' by itself" do
        @grammar.parse('Material referred to <i>rufa</i> by Yarrow, 1955a: 4',
                      :root => :history_item).value_with_reference_text_removed.should == {
          :material_referred_to => {
            :species_epithet => 'rufa',
            :references => [{:author_names => ['Yarrow'], :year => '1955a', :pages => '4'}]
          }
        }
      end
      it "should handle a colon instead of 'by'" do
        @grammar.parse('Material referred to <i>gnava</i>: Wheeler, W.M. 1913f: 518',
                      :root => :history_item).value_with_reference_text_removed.should == {
          :material_referred_to => {
            :species_epithet => 'gnava',
            :references => [{:author_names => ['Wheeler, W.M.'], :year => '1913f', :pages => '518'}]
          }
        }
      end
    end

    describe "Misspellings" do
      it "should parse a misspelling" do
        @grammar.parse('Misspelled as <i>paucistriatus</i> by Kempf, 1972a: 109',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :misspellings => [{:species_epithet => 'paucistriatus',
            :references => [{:author_names => ['Kempf'], :year => '1972a', :pages => '109'}]
          }]
        }
      end
      it "should parse multiple misspellings" do
        @grammar.parse('Misspelled as <i>fukali</i> by Emery, 1925b: 257 and as <i>fukalii</i> by Wu, 1990: 5',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :misspellings => [
            {:species_epithet => 'fukali',
             :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '257'}]},
            {:species_epithet => 'fukalii',
             :references => [{:author_names => ['Wu'], :year => '1990', :pages => '5'}]},
          ]
        }
      end
      it "should parse a misspelling with slightly different phrasing" do
        @grammar.parse('Name misspelled <i>subsericeorufibarbis</i> by Emery, 1925b: 250',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :misspellings => [{:species_epithet => 'subsericeorufibarbis',
            :references => [{:author_names => ['Emery'], :year => '1925b', :pages => '250'}]
          }]
        }
      end

    end

    describe "green entries" do
      it "should parse an unidentifiable taxon" do
        @grammar.parse('Unidentifiable taxon: Bolton, 1995b: 190',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unidentifiable => {
            :references => [{:author_names => ['Bolton'], :year => '1995b', :pages => '190'}]
          }
        }
      end
      it "should parse an unidentifiable as to genus" do
        @grammar.parse('Unidentifiable to genus; <i>incertae sedis</i> in <i>Formica</i>: Bolton, 1995b: 190',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unidentifiable => {
            :references => [{:author_names => ['Bolton'], :year => '1995b', :pages => '190'}]
          }
        }
      end
      it "should parse an unidentifiable taxon incertae sedis in Formica" do
        @grammar.parse('Unidentifiable taxon, <i>incertae sedis</i> in <i>Formica</i>: Seifert, 2004: 32',
                       :root => :history_item).value_with_reference_text_removed.should == {
          :unidentifiable => {
            :references => [{:author_names => ['Seifert'], :year => '2004', :pages => '32'}]
          }
        }
      end

    end

    describe "see also" do
      it "should handle a normal one" do
        @grammar.parse('See also: Cuezzo, 2000: 253', :root => :history_item).value_with_reference_text_removed.should == {
          :see_also => {
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '253'}]
          }
        }
      end
      it "should handle it when there's no space" do
        @grammar.parse('See also:Cuezzo, 2000: 253', :root => :history_item).value_with_reference_text_removed.should == {
          :see_also => {
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '253'}]
          }
        }
      end
      it "should handle 'see also comment in'" do
        @grammar.parse('See also comment in Cuezzo, 2000: 253', :root => :history_item).value_with_reference_text_removed.should == {
          :see_also => {
            :text => 'See also comment in',
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '253'}]
          }
        }
      end
      it "should handle 'See:'" do
        @grammar.parse('See: Cuezzo, 2000: 253', :root => :history_item).value_with_reference_text_removed.should == {
          :see_also => {
            :text => 'See:',
            :references => [{:author_names => ['Cuezzo'], :year => '2000', :pages => '253'}]
          }
        }
      end
      it "should 'See also comment in... " do
        @grammar.parse('See also comment in Seifert, 2002b: 267', :root => :history_item).value_with_reference_text_removed.should == {
          :see_also => {
            :text => 'See also comment in',
            :references => [{:author_names => ['Seifert'], :year => '2002b', :pages => '267'}]
          }
        }
      end

    end

    it "should parse 'Current subspecies'" do
      @grammar.parse("Current subspecies: nominal plus <i>alpina</i>, <i>whymperi</i> (unresolved junior homonym)",
                     :root => :current_subspecies).value_with_reference_text_removed.should == {
        :subspecies => [{:species_group_epithet => 'alpina'}, {:species_group_epithet => 'whymperi', :unresolved_homonym => true}]
      }
    end
  end

  describe "'see under' lines" do
    describe "species 'see under' lines" do
      it "should detect 'see under' lines" do
        @grammar.parse("<i>eidmanni</i> Goetsch, 1933; see under <i>TAPINOMA</i>.").value_with_reference_text_removed.should == {:type => :species_see_under}
      end
      it "should detect 'see under' lines" do
        @grammar.parse("<i>emeryi</i> Forel, 1915: see under <i>PSEUDOLASIUS</i>.").value_with_reference_text_removed.should == {:type => :species_see_under}
      end
      it "should parse 'see under' lines" do
        @grammar.parse(%{<i>eidmanni</i> Goetsch, 1933; see under <i>TAPINOMA</i>.})
      end
      it "should detect 'see under' lines with page numbers" do
        @grammar.parse("<i>eidmanni</i> Goetsch, 1933: 68; see under <i>TAPINOMA</i>.",
                       :root => :species_see_under)
      end
      it "should detect 'see under' without ending period" do
        @grammar.parse("<i>opaca</i> Nylander, 1856; see under <i>CAMPONOTUS</i>", :root => :species_see_under)
      end
      it "should detect fossil 'see under' lines" do
        @grammar.parse("*<i>freyeri</i> Heer, 1867; see under *<i>LONCHOMYRMEX</i>.",
                       :root => :species_see_under)
      end
      it "should detect Smith's 'see under' lines" do
        @grammar.parse("<i>eidmanni</i> Smith, F. 1933; see under <i>TAPINOMA</i>.",
                       :root => :species_see_under)
      end
      it "should detect fossil 'see under' lines" do
        @grammar.parse("*<i>freyeri</i> Heer, 1867; see under *<i>LONCHOMYRMEX</i>.",
                       :root => :species_see_under)
      end
      it "should detect 'see under' lines with notes" do
        @grammar.parse("<i>hybrida</i> Emery, 1916 [<i>Formicina</i>]; see under <i>LASIUS</i>.",
                       :root => :species_see_under)
      end
      it "should detect a species see-under that points to a species" do
        @grammar.parse("<i>major</i> Santschi, 1916; see under <i>grandis</i>, above.", :root => :species_see_under)
      end
      it "should detect a species see-under where the species name isn't italicized" do
        @grammar.parse("dimidiata Forel, 1911: see under <i>ACROMYRMEX</i>.", :root => :species_see_under)
      end
      it "should detect a species see-under with a nested reference" do
        @grammar.parse("<i>fuscoptera</i> Geoffroy, in Fourcroy, 1785; see under <i>CAMPONOTUS</i>.", :root => :species_see_under)
      end
      it "should detect 'see under' line with comma after authorship" do
        @grammar.parse("<i>maroccanus</i> Santschi, 1926, see under <i>NEIVAMYRMEX</i>.", :root => :species_see_under)
      end
      it "should detect 'see under' line with comma after authorship" do
        @grammar.parse("<i>furmanni</i>; see <i>fuhrmanni</i>, above.", :root => :species_see_under)
      end
      it "should detect 'see under' line with comma after authorship" do
        @grammar.parse("<i>geei</i> Brown, 1953; see under <i>PRENOLEPIS</i> (<i>P. emmae</i>).", :root => :species_see_under)
      end
      it "should detect 'see under...above'" do
        @grammar.parse("<i>nigricans</i>: see <i>nigrescens</i>, above.", :root => :species_see_under)
      end
    end

    describe "Genus see-under lines" do
      it "should detect genus 'see under' lines" do
        @grammar.parse("<i>FLORENCEA</i>: see under <i>POLYRHACHIS</i>.").value_with_reference_text_removed.should == {:type => :genus_see_under}
      end
      it "should detect subgenus 'see under' lines" do
        @grammar.parse("<i>ACANTHOMYOPS</i>: see under <i>LASIUS</i>.", :root => :genus_see_under)
      end
      it "should detect fossil genus 'see under' line with authorship" do
        @grammar.parse("*<i>ACROSTIGMA</i> Emery: see under <i>PODOMYRMA</i>.", :root => :genus_see_under)
      end
      it "should handle it when there's no colon" do
        @grammar.parse(%{<i>ASKETOGENYS</i> see under <i>PYRAMICA</i>.}, :root => :genus_see_under)
      end
      it "should handle it when there's a space before the colon" do
        @grammar.parse(%{<i>MACROMISCHOIDES</i> : see under <i>TETRAMORIUM</i>.}, :root => :genus_see_under)
      end
      it "should handle a transfer" do
        @grammar.parse(%{*<i>PALAEOMYRMEX</i> Heer, 1865: transferred to <i>HOMOPTERA</i>.}, :root => :genus_see_under)
      end

    end

  end

  it "should parse an unparseable senior synonym list with a parenthesis, followed by a regular history item" do
    @grammar.parse("Senior synonym of *<i>antiqua</i>, *<i>baltica</i>, *<i>parvula</i>: Dlussky, 2002a: 292; (replacement name for *<i>parvula</i> Dlussky, proposed subsequent to Dlussky's 2002a synonymy and hence automatic junior synonym). See also: Dlussky, 1967b: 81.", :root => :history).value_with_reference_text_removed.should == {
      :history => [
        {:senior_synonym_ofs => [{
          :junior_synonyms => [
            {:species_epithet => 'antiqua', :fossil => true},
            {:species_epithet => 'baltica', :fossil => true},
            {:species_epithet => 'parvula', :fossil => true},
          ],
          :references => [{:author_names => ['Dlussky'], :year => '2002a', :pages => '292'}],
        }]},
        {:text => [
          {:opening_parenthesis => '('},
          {:phrase => 'replacement name for', :delimiter => ' '},
          {:species_group_epithet => 'parvula', :authorship => [{:author_names => ['Dlussky']}], :fossil => true},
          {:phrase => ", proposed subsequent to Dlussky's 2002a synonymy and hence automatic junior synonym"},
          {:closing_parenthesis => ")"},
          {:delimiter => "."},
        ]},
        {:see_also => {
          :references => [{:author_names => ['Dlussky'], :year => '1967b', :pages => '81'}]
        }},
    ]}
  end

  describe "Genus header" do
    it "should parse a genus header" do
      @grammar.parse("*<i>FALLOMYRMA</i>").value.should == {:type => :genus_header, :name => 'Fallomyrma'}
    end
    it "should parse an ichnotaxon" do
      @grammar.parse("*<i>ATTAICHNUS</i> (ichnotaxon)").value.should == {:type => :genus_header, :name => 'Attaichnus'}
    end
    it "should parse a fossil with italicized phrase" do
      @grammar.parse("*<i>MYRMICIUM</i> (Symphyta)").value.should == {:type => :genus_header, :name => 'Myrmicium'}
    end
  end

  describe "subspecies lists" do
    it "should parse a subspecies list item that's an unresolved junior homonym" do
      @grammar.parse("<i>alpina</i> (unresolved junior homonym)", :root => :subspecies_list_item).value.should ==
        {:species_group_epithet => 'alpina', :unresolved_homonym => true}
    end
  end

  it "should parse the catalog header" do
    @grammar.parse("CATALOGUE OF SPECIES-GROUP TAXA").value.should == {:type => :catalog_header}
  end

  describe "Locality" do
    it "should parse this one with phrase and parentheses" do
      @grammar.parse('no type-locality given (type-locality AUSTRALIA: Shattuck, 2008c: 4)', :root => :locality)
    end
    it "should parse locality" do
      @grammar.parse('BRAZIL', :root => :locality).value.should == 'Brazil'
    end
    it "should handle a space and a ?" do
      @grammar.parse('EGYPT ?', :root => :locality).value.should == 'Egypt ?'
    end
    it "should handle a ?" do
        @grammar.parse('EGYPT?', :root => :locality).value.should == 'Egypt?'
    end
    it "should parse U.S.A." do
      @grammar.parse('U.S.A.', :root => :locality).value.should == 'U.S.A.'
    end
    it "should parse U.S.A.?" do
      @grammar.parse('U.S.A.?', :root => :locality).value.should == 'U.S.A.?'
    end
    it "should parse U.S.A. (Eocene)" do
      @grammar.parse('U.S.A. (Eocene)', :root => :locality).value.should == 'U.S.A. (Eocene)'
    end
    it "should accept a quoted locality followed by a parenthesized note" do
      @grammar.parse('"GUINEA" (in error; in text Forel states "probablement du Brésil")', :root => :locality)
    end

    # This seems to fail because of the nested parenthesis
    #it "should accept a quoted phrase followed by a parenthesized note" do
      #@grammar.parse('"am Schiffe gefunden" (type-locality INDONESIA (Sumatra), see Emery, 1896d: 374)', :root => :locality)
    #end

    it "should parse a two-word locality with a slash (and a question mark!)" do
      @grammar.parse('CHINA/KASHMIR?', :root => :locality).value.should == 'China/Kashmir?'
    end
    it "should parse and lowercase accented characters" do
      @grammar.parse('SÃO TOMÉ & PRÍNCIPE (São Tomé I.)', :root => :locality).value.should ==  "São Tomé & Príncipe (São Tomé I.)"
    end
    it "should parse a two-word locality with parenthesis" do
      @grammar.parse('BALTIC AMBER (Eocene)', :root => :locality).value.should == 'Baltic Amber (Eocene)'
    end
    it "should parse a locality with two-word parenthesis" do
      @grammar.parse('UKRAINE (Rovno Amber)', :root => :locality).value.should == 'Ukraine (Rovno Amber)'
    end
    it "should parse a locality in quotes" do
      @grammar.parse('"Grandes Indes"', :root => :locality).value.should == '"Grandes Indes"'
    end
    it "should parse 'no locality given'" do
      @grammar.parse('no locality given', :root => :locality).value.should == 'no locality given'
    end
    it "should parse 'no locality'" do
      @grammar.parse('no locality', :root => :locality).value.should == 'no locality'
    end
    it "should parse 'error in locality'" do
      @grammar.parse('"South America"; locality in error', :root => :locality).value.should == '"South America"; locality in error'
    end
    it "should parse '(locality in error)'" do
      @grammar.parse('INDONESIA (Sumatra) (locality in error)', :root => :locality).value.should == 'Indonesia (Sumatra) (locality in error)'
    end
  end

end
