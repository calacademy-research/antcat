# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::TribeGrammar do
  before do
    @grammar = Bolton::Catalog::Subfamily::TribeGrammar
  end

  describe "Tribe header" do
    it "should be recognized" do
      @grammar.parse(%{Tribe MYRMECIINI}).value_with_reference_text_removed.should == {:type => :tribe_header, :name => 'Myrmeciini'}
    end
    it "should be recognized when it's extinct" do
      @grammar.parse(%{Tribe *MIOMYRMECINI}).value_with_reference_text_removed.should == {:type => :tribe_header, :name => 'Miomyrmecini', :fossil => true}
    end
    it "should be recognized when the asterisk is in a different place" do
      @grammar.parse(%{Tribe *PITYOMYRMECINI}).value_with_reference_text_removed.should == {:type => :tribe_header, :name => 'Pityomyrmecini', :fossil => true}
    end
  end

  describe "Junior synonyms of tribe header" do
    it "should be recognized" do
      @grammar.parse(%{Junior synonym of ECTATOMMINI}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_tribe_header}
    end
    it "should be recognized when plural" do
      @grammar.parse(%{Junior synonyms of LEPTOMYRMECINI}).value_with_reference_text_removed.should == {:type => :junior_synonyms_of_tribe_header}
    end
  end

  describe "Genera incertae sedis in tribe" do
    it "should be recognized" do
      @grammar.parse(%{Genus <i>incertae sedis</i> in Heteroponerini}).value_with_reference_text_removed.should == {:type => :genera_incertae_sedis_in_tribe_header}
    end
  end

  describe "Tribes incertae sedis in subfamily header" do
    it "should be recognized" do
      @grammar.parse(%{Tribes (extinct) <i>incertae sedis</i> in DOLICHODERINAE}).value_with_reference_text_removed.should == {:type => :tribes_incertae_sedis_header}
    end
  end

  describe "Taxonomic history items" do
    it "should parse 'tribe of'" do
      @grammar.parse(%{Aneuretini as tribe of Dolichoderinae: Emery, 1913a: 6; all subsequent authors.}, :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :tribe_taxonomic_history_item,
          :tribe => {:tribe_name => 'Aneuretini'},
          :tribe_of => {:subfamily_name => 'Dolichoderinae'},
          :references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '6'},
            {:subsequent_authors => 'all subsequent authors'},
          ],
        }
    end
    it "should parse 'subtribe of'" do
      @grammar.parse(%{Stictoponerini as subtribe of Aneuretini: Arnol'di, 1930d: 161.}, :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :tribe_taxonomic_history_item,
          :tribe => {:tribe_name => 'Stictoponerini'},
          :subtribe_of => {:tribe_name => 'Aneuretini'},
          :references => [{:author_names => ["Arnol'di"], :year => '1930d', :pages => '161'}],
        }
    end
    it "should parse a subtribe 'as subtribe of'" do
      @grammar.parse(%{Bothriomyrmecina as subtribe of Iridomyrmecini: Dubovikov, 2005a: 92.}, :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :tribe_taxonomic_history_item,
          :tribe => {:subtribe_name => 'Bothriomyrmecina'},
          :subtribe_of => {:tribe_name => 'Iridomyrmecini'},
          :references => [{:author_names => ["Dubovikov"], :year => '2005a', :pages => '92'}],
        }
    end
    it "should parse 'junior synonym of'" do
      @grammar.parse(%{*Pityomyrmecini as junior synonym of Dolichoderinae: Shattuck, 1992c: 5.}, :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :tribe_taxonomic_history_item,
          :tribe => {:tribe_name => 'Pityomyrmecini', :fossil => true},
          :as_junior_synonym_of => {:subfamily => {:subfamily_name => 'Dolichoderinae'}},
          :references => [{:author_names => ['Shattuck'], :year => '1992c', :pages => '5'}],
        }
    end

    it "should parse 'junior synonym of' a tribe" do
      @grammar.parse('Anonychomyrmini as junior synonym of Leptomyrmecini: Ward, Brady, <i>et al.</i> 2010: 361.', :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should == {:type => :tribe_taxonomic_history_item,
        :tribe => {:tribe_name => 'Anonychomyrmini'},
        :as_junior_synonym_of => {:tribe => {:tribe_name => 'Leptomyrmecini'}},
        :references => [{:author_names => ['Ward', 'Brady', '<i>et al.</i>'], :year => '2010', :pages => '361'}],
        }
    end

    it "should parse 'incertae sedis in <subfamily>'" do
      @grammar.parse(%{*Pityomyrmecini <i>incertae sedis</i> in Dolichoderinae: Ward, Brady, <i>et al.</i> 2010: 362.}, :root => :tribe_taxonomic_history_item).value_with_reference_text_removed.should == {
        :type => :tribe_taxonomic_history_item,
        :tribe => {:tribe_name => "Pityomyrmecini", :fossil => true},
        :incertae_sedis_in => [{:subfamily_name => 'Dolichoderinae'}],
        :references => [
          {:author_names => ['Ward', 'Brady', '<i>et al.</i>'], :year => '2010', :pages => '362'},
        ],
      }
    end
  end

  describe "Ichnotaxon" do
    it "list should be recognized" do
      @grammar.parse('Ichnotaxon: *<i>Attaichnus</i>.').value_with_reference_text_removed.should == {
        :type => :ichnotaxa_list, :genus => {:genus_name => 'Attaichnus', :fossil => true}
      }
    end

    it "items should be recognized" do
      @grammar.parse('Ichnotaxon attached to Attini', :root => :ichnotaxa_header).value_with_reference_text_removed.should == {
        :type => :ichnotaxa_header
      }
    end

  end

  describe "References header" do
    before do
      @grammar = Bolton::Catalog::Subfamily::Grammar
    end
    it "should handle references for the tribe when the name is left out" do
      @grammar.parse('Tribe references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        :taxa => {:tribe => true}
      }
    end
    it "should handle a see also references header" do
      @grammar.parse('See also general references under PONERINAE.').value_with_reference_text_removed.should == {
        :type => :see_also_references_section_header,
        :taxa => {:family_or_subfamily_name => 'Ponerinae'}
      }
    end
    it "should handle references for a see above tribe" do
      @grammar.parse('Tribe Ecitonini references: see above').value_with_reference_text_removed.should == {
        :type => :see_under_references_section_header,
        :taxa => {:tribe_name => 'Ecitonini'}
      }
    end
    it "should handle references for a see above tribe, not named" do
      @grammar.parse('Tribe references: see above').value_with_reference_text_removed.should == {
        :type => :see_under_references_section_header,
        :taxa => :tribe
      }
    end
    it "should handle references for a single tribe" do
      @grammar.parse('Tribe Aneuretini references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        :taxa => {:tribe_name => 'Aneuretini'}
      }
    end
    it "should handle references for the tribe and a genus" do
      @grammar.parse('Tribe and genus <i>Myrmoteras</i> references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        :taxa => {:genus_name => 'Myrmoteras'}
      }
    end
    it "should handle references for the subfamily and tribe" do
      @grammar.parse('Subfamily and tribe Pseudomyrmecini references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        :taxa => {:subfamily => true, :tribe_name => 'Pseudomyrmecini'}
      }
    end
    it "should handle a header that also includes a reference" do
      @grammar.parse('Tribe references: see under genera; Bolton, 2003: 30.').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        :texts => [
          :text => [
            {:author_names => ['Bolton'], :year => '2003', :pages => '30'},
          ]
        ],
      }
    end
  end
end
