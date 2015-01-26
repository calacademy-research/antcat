# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::TribeGrammar do
  before do
    @grammar = Importers::Bolton::Catalog::Subfamily::TribeGrammar
  end

  describe "Tribe header" do
    it "should be recognized" do
      expect(@grammar.parse(%{Tribe MYRMECIINI}).value_with_matched_text_removed).to eq({:type => :tribe_header, :name => 'Myrmeciini'})
    end
    it "should be recognized when it's extinct" do
      expect(@grammar.parse(%{Tribe *MIOMYRMECINI}).value_with_matched_text_removed).to eq({:type => :tribe_header, :name => 'Miomyrmecini', :fossil => true})
    end
    it "should be recognized when the asterisk is in a different place" do
      expect(@grammar.parse(%{Tribe *PITYOMYRMECINI}).value_with_matched_text_removed).to eq({:type => :tribe_header, :name => 'Pityomyrmecini', :fossil => true})
    end
  end

  describe "Junior synonyms of tribe header" do
    it "should be recognized" do
      expect(@grammar.parse(%{Junior synonym of ECTATOMMINI}).value_with_matched_text_removed).to eq({:type => :junior_synonyms_of_tribe_header})
    end
    it "should be recognized when plural" do
      expect(@grammar.parse(%{Junior synonyms of LEPTOMYRMECINI}).value_with_matched_text_removed).to eq({:type => :junior_synonyms_of_tribe_header})
    end
  end

  describe "Genera incertae sedis in tribe" do
    it "should be recognized in the singular" do
      expect(@grammar.parse(%{Genus <i>incertae sedis</i> in Heteroponerini}).value_with_matched_text_removed).to eq({:type => :genera_incertae_sedis_in_tribe_header})
    end
    it "should be recognized in the plural" do
      expect(@grammar.parse(%{Genera <i>incertae sedis</i> in Heteroponerini}).value_with_matched_text_removed).to eq({:type => :genera_incertae_sedis_in_tribe_header})
    end
  end

  describe "Tribes incertae sedis in subfamily header" do
    it "should be recognized" do
      expect(@grammar.parse(%{Tribes (extinct) <i>incertae sedis</i> in DOLICHODERINAE}).value_with_matched_text_removed).to eq({:type => :tribes_incertae_sedis_header})
    end
  end

  describe "Taxonomic history items" do
    it "should parse 'tribe of'" do
      expect(@grammar.parse(%{Aneuretini as tribe of Dolichoderinae: Emery, 1913a: 6; all subsequent authors.}, :root => :tribe_history_item).value_with_matched_text_removed).to eq(
        {:type => :tribe_history_item,
          :tribe => {:tribe_name => 'Aneuretini'},
          :tribe_of => {:subfamily_name => 'Dolichoderinae'},
          :references => [
            {:author_names => ['Emery'], :year => '1913a', :pages => '6'},
            {:subsequent_authors => 'all subsequent authors'},
          ],
        }
      )
    end
    it "should parse 'subtribe of'" do
      expect(@grammar.parse(%{Stictoponerini as subtribe of Aneuretini: Arnol'di, 1930d: 161.}, :root => :tribe_history_item).value_with_matched_text_removed).to eq(
        {:type => :tribe_history_item,
          :tribe => {:tribe_name => 'Stictoponerini'},
          :subtribe_of => {:tribe_name => 'Aneuretini'},
          :references => [{:author_names => ["Arnol'di"], :year => '1930d', :pages => '161'}],
        }
      )
    end
    it "should parse a subtribe 'as subtribe of'" do
      expect(@grammar.parse(%{Bothriomyrmecina as subtribe of Iridomyrmecini: Dubovikov, 2005a: 92.}, :root => :tribe_history_item).value_with_matched_text_removed).to eq(
        {:type => :tribe_history_item,
          :tribe => {:subtribe_name => 'Bothriomyrmecina'},
          :subtribe_of => {:tribe_name => 'Iridomyrmecini'},
          :references => [{:author_names => ["Dubovikov"], :year => '2005a', :pages => '92'}],
        }
      )
    end
    it "should parse 'junior synonym of'" do
      expect(@grammar.parse(%{*Pityomyrmecini as junior synonym of Dolichoderinae: Shattuck, 1992c: 5.}, :root => :tribe_history_item).value_with_matched_text_removed).to eq(
        {:type => :tribe_history_item,
          :tribe => {:tribe_name => 'Pityomyrmecini', :fossil => true},
          :as_junior_synonym_of => {:subfamily => {:subfamily_name => 'Dolichoderinae'}},
          :references => [{:author_names => ['Shattuck'], :year => '1992c', :pages => '5'}],
        }
      )
    end

    it "should parse 'junior synonym of' a tribe" do
      expect(@grammar.parse('Anonychomyrmini as junior synonym of Leptomyrmecini: Ward, Brady, <i>et al.</i> 2010: 361.', :root => :tribe_history_item).value_with_matched_text_removed).to eq({:type => :tribe_history_item,
        :tribe => {:tribe_name => 'Anonychomyrmini'},
        :as_junior_synonym_of => {:tribe => {:tribe_name => 'Leptomyrmecini'}},
        :references => [{:author_names => ['Ward', 'Brady', '<i>et al.</i>'], :year => '2010', :pages => '361'}],
        })
    end

    it "should parse 'incertae sedis in <subfamily>'" do
      expect(@grammar.parse(%{*Pityomyrmecini <i>incertae sedis</i> in Dolichoderinae: Ward, Brady, <i>et al.</i> 2010: 362.}, :root => :tribe_history_item).value_with_matched_text_removed).to eq({
        :type => :tribe_history_item,
        :tribe => {:tribe_name => "Pityomyrmecini", :fossil => true},
        :incertae_sedis_in => [{:subfamily_name => 'Dolichoderinae'}],
        :references => [
          {:author_names => ['Ward', 'Brady', '<i>et al.</i>'], :year => '2010', :pages => '362'},
        ],
      })
    end
  end

  describe "Ichnotaxon" do
    it "list should be recognized" do
      expect(@grammar.parse('Ichnotaxon: *<i>Attaichnus</i>.').value_with_matched_text_removed).to eq({
        :type => :ichnotaxa_list, :genus => {:genus_name => 'Attaichnus', :fossil => true}
      })
    end

    it "items should be recognized" do
      expect(@grammar.parse('Ichnotaxon attached to Attini', :root => :ichnotaxa_header).value_with_matched_text_removed).to eq({
        :type => :ichnotaxa_header
      })
    end

  end

  describe "References header" do
    before do
      @grammar = Importers::Bolton::Catalog::Subfamily::Grammar
    end
    it "should handle references for the tribe when the name is left out" do
      expect(@grammar.parse('Tribe references').value_with_matched_text_removed).to eq({
        type: :references_section_header,
        title: 'Tribe references'
      })
    end
    it "should handle a see also references header" do
      expect(@grammar.parse('See also general references under PONERINAE.').value_with_matched_text_removed).to eq({
        :type => :see_also_references_section_header,
        title: 'See also general references under PONERINAE.'
      })
    end
    it "should handle references for a see above tribe" do
      expect(@grammar.parse('Tribe Ecitonini references: see above').value_with_matched_text_removed).to eq({
        :type => :see_under_references_section_header,
        title: 'Tribe Ecitonini references: see above'
      })
    end
    it "should handle references for a see above tribe, not named" do
      expect(@grammar.parse('Tribe references: see above').value_with_matched_text_removed).to eq({
        :type => :see_under_references_section_header,
        title: 'Tribe references: see above'
      })
    end
    it "should handle references for a single tribe" do
      expect(@grammar.parse('Tribe Aneuretini references').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Tribe Aneuretini references'
      })
    end
    it "should handle references for the tribe and a genus" do
      expect(@grammar.parse('Tribe and genus <i>Myrmoteras</i> references').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Tribe and genus <i>Myrmoteras</i> references'
      })
    end
    it "should handle references for the subfamily and tribe" do
      expect(@grammar.parse('Subfamily and tribe Pseudomyrmecini references').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Subfamily and tribe Pseudomyrmecini references'
      })
    end
    it "should handle a header that also includes a reference" do
      expect(@grammar.parse('Tribe references: see under genera; Bolton, 2003: 30.').value_with_matched_text_removed).to eq({
        :type => :references_section_header,
        title: 'Tribe references: see under genera; Bolton, 2003: 30.'
      })
    end
  end
end
