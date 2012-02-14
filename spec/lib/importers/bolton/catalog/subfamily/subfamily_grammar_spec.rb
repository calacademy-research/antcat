# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::SubfamilyGrammar do
  before do
    @grammar = Importers::Bolton::Catalog::Subfamily::SubfamilyGrammar
  end

  describe "Header" do
    it "should recognize a subfamily centered header" do
      @grammar.parse(%{SUBFAMILY ANEURETINAE}).value_with_reference_text_removed.should == {:type => :subfamily_centered_header}
    end
    it "should recognize the subfamily centered header for an extinct subfamily" do
      @grammar.parse(%{SUBFAMILY *ARMANIINAE}).value_with_reference_text_removed.should == {:type => :subfamily_centered_header}
    end
    it "should recognize the subfamily header for an extinct subfamily" do
      @grammar.parse(%{Subfamily *ARMANIINAE}).value_with_reference_text_removed.should == {:type => :subfamily_header, :name => 'Armaniinae', :fossil => true}
    end
    it "should recognize a subfamily header" do
      @grammar.parse(%{Subfamily MYRMICINAE}).value_with_reference_text_removed.should == {:type => :subfamily_header, :name => 'Myrmicinae'}
    end
    it "should recognize an extinct subfamily header" do
      @grammar.parse(%{Subfamily *ARMANIINAE}).value_with_reference_text_removed.should == {:type => :subfamily_header, :name => 'Armaniinae', :fossil => true}
    end
  end

  describe "Lists" do

    describe "Tribes list" do
      it "should recognize a tribes list" do
        @grammar.parse(%{Tribes of Aneuretinae: Aneuretini, *Pityomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end
      it "should recognize an extinct tribes list" do
        @grammar.parse(%{Tribes (extinct) of Aneuretinae: Aneuretini, *Pityomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end
      it "should recognize an extant tribes list" do
        @grammar.parse(%{Tribes (extant) of Aneuretinae: Aneuretini, *Pityomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end
      it "should recognize an tribes list with one tribe" do
        @grammar.parse(%{Tribe of Aneuretinae: Aneuretini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}]}
      end
      it "should recognize a tribes incertae sedis list" do
        @grammar.parse(%{Tribes <i>incertae sedis</i> in Aneuretinae: *Miomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Miomyrmecini', :fossil => true}], :incertae_sedis => true}
      end
      it "should recognize an extinct tribes incertae sedis list" do
        @grammar.parse(%{Tribes (extinct) <i>incertae sedis</i> in Dolichoderinae: *Miomyrmecini, *Zherichiniini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Miomyrmecini', :fossil => true}, {:name => 'Zherichiniini', :fossil => true}], :incertae_sedis => true}
      end
      it "should be recognized when the list doesn't include the subfamily name" do
        @grammar.parse(%{Tribe: Pseudomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Pseudomyrmecini'}]}
      end
      it "should be recognized with an extinct subfamily" do
        @grammar.parse(%{Tribes of *Sphecomyrminae: *Haidomyrmecini.}).value_with_reference_text_removed.should == {:type => :tribes_list, :tribes => [{:name => 'Haidomyrmecini', :fossil => true}]}
      end
    end

    describe "Genera lists" do
      it "should recognize a genera list" do
        @grammar.parse(%{Genera of Aneuretinae: <i>Burmomyrma</i>, *<i>Cananeuretus</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus', :fossil => true}]}
      end
      it "should recognize a genera list without a period" do
        @grammar.parse(%{Genus: <i>Notostigma</i> }).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Notostigma'}]}
      end
      it "should recognize a genera list with just one extinct genus" do
        @grammar.parse(%{Genus: *<i>Pityomyrmex</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Pityomyrmex', :fossil => true}]}
      end
      it "should be recognized with the period well after the end of the list" do
        @grammar.parse(%{Genus: *<i>Miomyrmex</i> (see under: Genera <i>incertae sedis</i> in Dolichoderinae, below).}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Miomyrmex', :fossil => true}]}
      end
      it "should be recognized with the period well after the end of the list" do
        @grammar.parse(%{Genus of Aenictogitonini: <i>Aenictogiton</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Aenictogiton'}]}
      end
      it "should be recognized for an extinct subfamily" do
        @grammar.parse(%{Genera (extinct) of *Armaniini: *<i>Archaeopone</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Archaeopone', :fossil => true}]}
      end
    end

    describe "Genera incertae sedis lists" do
      it "should recognize a genera incertae sedis list" do
        @grammar.parse(%{Genera <i>incertae sedis</i> in Aneuretinae: <i>Burmomyrma</i>, *<i>Cananeuretus</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus', :fossil => true}]}
      end
      it "should recognize an extinct genera incertae sedis list" do
        @grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in Aneuretinae: *<i>Burmomyrma</i>, *<i>Cananeuretus</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma', :fossil => true}, {:name => 'Cananeuretus', :fossil => true}]}
      end
      it "should recognize an extinct genera incertae sedis list" do
        @grammar.parse(%{Genus <i>incertae sedis</i> in Gesomyrmecini: *<i>Prodimorphomyrmex</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Prodimorphomyrmex', :fossil => true}]}
      end
      it "should recognize an extant genera incertae sedis list" do
        @grammar.parse(%{Genera (extant) <i>incertae sedis</i> in Aneuretinae: <i>Burmomyrma</i>, <i>Cananeuretus</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus'}]}
      end
      it "should recognize a Hong 2002 genera incertae sedis list, and handle an unresolved junior homonym in it" do
        @grammar.parse(%{Hong (2002) genera (extinct) <i>incertae sedis</i> in Formicinae: *<i>Curtipalpulus</i> (unresolved junior homonym).}).value_with_reference_text_removed.should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Curtipalpulus', :fossil => true, :status => 'unresolved homonym'}]}
      end
      it "for a supersubfamily should be recognized" do
        @grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in poneroid subfamilies: *<i>Cretopone</i>, *<i>Petropone</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Cretopone', :fossil => true}, {:name => 'Petropone', :fossil => true}], :incertae_sedis => true}
      end
      it "for a supersubfamily with a different name should be recognized" do
        @grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in poneromorph subfamilies: *<i>Cretopone</i>, *<i>Petropone</i>.}).value_with_reference_text_removed.should == {:type => :genera_list, :genera => [{:name => 'Cretopone', :fossil => true}, {:name => 'Petropone', :fossil => true}], :incertae_sedis => true}
      end
    end

    it "should recognize a collective group name list" do
      @grammar.parse(%{Collective group name in Myrmeciinae: *<i>Myrmeciites</i>.}).value_with_reference_text_removed.should == {:type => :collective_group_name_list, :names => [{:name => 'Myrmeciites', :fossil => true}]}
    end

    describe "Parsing a group of list names" do
      it "should recognize one name" do
        Importers::Bolton::Catalog::Subfamily::Grammar.parse("*<i>Myrmeciites</i>.", :root => :list_names).value_with_reference_text_removed.should == [{:name => 'Myrmeciites', :fossil => true}]
      end
      it "should recognize more than one name" do
        Importers::Bolton::Catalog::Subfamily::Grammar.parse(%{*<i>Myrmeciites</i>, <i>Petropone</i>.}, :root => :list_names).value_with_reference_text_removed.should ==
          [{:name => 'Myrmeciites', :fossil => true}, {:name => 'Petropone'}]
      end
    end

    describe "Collective group names header" do
      it "should be recognized" do
        @grammar.parse(%{Collective group name in MYRMICINAE}).value_with_reference_text_removed.should == {:type => :collective_group_names_header}
      end
    end

  end

  describe "Taxonomic history items" do

    it "should parse 'junior synonym of'" do
      @grammar.parse(%{Aneuretinae as junior synonym of Dolichoderinae: Baroni Urbani, 1989: 147.}, :root => :subfamily_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :subfamily_taxonomic_history_item,
          :subfamily => {:subfamily_name => 'Aneuretinae'},
          :junior_synonym_of => {:subfamily_name => 'Dolichoderinae'},
          :references => [{:author_names => ['Baroni Urbani'], :year => '1989', :pages => '147'}],
        }
    end
    it "should parse 'as subfamily of Formicidae'" do
      @grammar.parse(%{Aneuretinae as subfamily of Formicidae: Clark, 1951: 16 (footnote); all subsequent authors.}, :root => :subfamily_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :subfamily_taxonomic_history_item,
          :subfamily => {:subfamily_name => 'Aneuretinae'},
          :as_subfamily => true,
          :references => [
            {:author_names => ['Clark'], :year => '1951', :pages => '16 (footnote)'},
            {:all_subsequent_authors => true},
          ],
        }
    end
    it "should parse 'as tribe of Formicidae'" do
      @grammar.parse(%{Dolichoderinae as tribe of Formicidae: André, 1882a: 127 [Dolichoderidae].}, :root => :subfamily_taxonomic_history_item).value_with_reference_text_removed.should ==
        {:type => :subfamily_taxonomic_history_item,
          :subfamily => {:subfamily_name => 'Dolichoderinae'},
          :as_tribe_of => {:family_name => 'Formicidae'},
          :references => [{:author_names => ['André'], :year => '1882a', :pages => '127', :note => '[Dolichoderidae]'}],
        }
    end
    it "should parse a kind of subfamily" do
      ['formicoid', 'formicomorph', 'formicoid dolichoderomorph'].each do |kind|
        @grammar.parse("Aneuretinae as #{kind} subfamily of Formicidae: Bolton, 2003: 18, 79.", :root => :subfamily_taxonomic_history_item).value_with_reference_text_removed.should ==
          {:type => :subfamily_taxonomic_history_item,
            :subfamily => {:subfamily_name => 'Aneuretinae'},
            :as_subfamily => true, :kind => kind,
            :references => [{:author_names => ['Bolton'], :year => '2003', :pages => '18, 79'}],
          }
      end
    end

    it "should recognize the history as a family" do
      @grammar.parse(%{Dolichoderinae as family: Emery, 1894g: 378 [Dolichoderidae].}, :root => :subfamily_taxonomic_history_item).value_with_reference_text_removed.should == {
        :type => :subfamily_taxonomic_history_item,
        :subfamily => {:subfamily_name => 'Dolichoderinae'},
        :as_family => true,
        :references => [{:author_names => ['Emery'], :year => '1894g', :pages => '378', :note => '[Dolichoderidae]'}]
      }
    end
  end

  describe "References" do
    before do
      @grammar = Importers::Bolton::Catalog::Subfamily::Grammar
    end

    it "should handle references for multiple taxa" do
      @grammar.parse('Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references').value_with_reference_text_removed.should == {
        type: :references_section_header,
        title: 'Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references'
      }
    end
    it "should handle these taxa" do
      @grammar.parse('Subfamily, tribe *Formiciini and collective group name *<i>Formicium</i> references').value_with_reference_text_removed.should == {
        :type=>:references_section_header,
        title: 'Subfamily, tribe *Formiciini and collective group name *<i>Formicium</i> references'
      }
    end

    it "should handle references for multiple when the tribe isn't specified" do
      @grammar.parse('Subfamily, tribe and genus <i>Myrmecia</i> references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        title: 'Subfamily, tribe and genus <i>Myrmecia</i> references'
      }
    end
    it "should handle world references for the subfamily" do
      @grammar.parse('Subfamily Formicinae references, world').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        title: 'Subfamily Formicinae references, world'
      }
    end
    it "should handle references for the subfamily" do
      @grammar.parse('Subfamily Formicinae references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        title: 'Subfamily Formicinae references'
      }
    end
    it "should handle references for the subfamily when the name is left out" do
      @grammar.parse('Subfamily references').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        title: 'Subfamily references'
      }
    end
    it "should handle world references for the subfamily and the tribes" do
      @grammar.parse('Subfamily Dolichoderinae and tribes references, world').value_with_reference_text_removed.should == {
        :type => :references_section_header,
        title: 'Subfamily Dolichoderinae and tribes references, world'
      }
    end
  end
end
