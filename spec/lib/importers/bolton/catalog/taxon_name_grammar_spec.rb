# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Grammar do
  before do
    @grammar = Importers::Bolton::Catalog::Grammar
  end

  describe "Taxon label" do
    it "matches an order name" do
      expect(@grammar.parse('Homoptera', :root => :taxon_label).value_with_matched_text_removed).to eq({:order_name => 'Homoptera'})
    end
    it "matches a family name" do
      expect(@grammar.parse('Formicidae', :root => :taxon_label).value_with_matched_text_removed).to eq({:family_or_subfamily_name => 'Formicidae'})
    end
    it "matches a subfamily name" do
      expect(@grammar.parse('Myrmicinae', :root => :taxon_label).value_with_matched_text_removed).to eq({:family_or_subfamily_name => 'Myrmicinae'})
    end
    it "matches a tribe name" do
      expect(@grammar.parse('Bothriomyrmecini', :root => :taxon_label).value_with_matched_text_removed).to eq({:tribe_name => 'Bothriomyrmecini'})
    end
    it "matches this weird tribe name" do
      expect(@grammar.parse('Platythyreini', :root => :taxon_label).value_with_matched_text_removed).to eq({:tribe_name => 'Platythyreini'})
    end
    it "matches a subtribe name" do
      expect(@grammar.parse('Bothriomyrmecina', :root => :taxon_label).value_with_matched_text_removed).to eq({:subtribe_name => 'Bothriomyrmecina'})
    end
    it "doesn't match 'Combination'" do
      expect {expect(@grammar.parse('Combination', root: :subtribe_name, consume: false).value_with_matched_text_removed).to eq({:subtribe_name => 'Bothriomyrmecina'})}.to raise_error Citrus::ParseError
    end
    it "matches a genus label" do
      expect(@grammar.parse('*<i>Atta</i>', :root => :taxon_label).value_with_matched_text_removed).to eq({:genus_name => 'Atta', :fossil => true})
    end
    it "matches a genus + subgenus label" do
      expect(@grammar.parse('<i>Atta (Atturus)</i>', :root => :taxon_label).value_with_matched_text_removed).to eq({:genus_name => 'Atta', :subgenus_epithet => 'Atturus'})
    end
    it "matches an abbreviated genus + subgenus label" do
      expect(@grammar.parse('<i>A. (Atturus)</i>', :root => :taxon_label).value_with_matched_text_removed).to eq({:genus_abbreviation => 'A.', :subgenus_epithet => 'Atturus'})
    end
    it "parses a genus abbreviation with two letters" do
      expect(@grammar.parse('<i>Pr. (Nylanderia)</i>', root: :taxon_label).value_with_matched_text_removed).to eq({genus_abbreviation: 'Pr.', subgenus_epithet: 'Nylanderia'})
    end
    it "should parse a collective group label" do
      result = @grammar.parse('*<i>Formicites</i> (collective group name)', root: :taxon_label, consume: false)
      expect(result).to eq('*<i>Formicites</i>')
      expect(result.value_with_matched_text_removed).to eq({collective_group_name: 'Formicites', fossil: true})
    end
    it "matches a species-group epithet label" do
      expect(@grammar.parse('<i>afar</i>', :root => :taxon_label).value_with_matched_text_removed).to eq({:species_group_epithet => 'afar'})
    end
    it "matches a species label" do
      expect(@grammar.parse('<i>Atta (Atturus) afar</i>', :root => :taxon_label).value_with_matched_text_removed).to eq(
        {:genus_name => 'Atta', :subgenus_epithet => 'Atturus', :species_epithet => 'afar'}
      )
    end
    it "matches a subspecies label" do
      expect(@grammar.parse('<i>Atta afar minor</i>', :root => :taxon_label).value_with_matched_text_removed).to eq(
        {:genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [{:subspecies_epithet => 'minor'}]}
      )
    end
    it "matches a subspecies label with an abbreviated genus" do
      expect(@grammar.parse('<i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90', :root => :taxon_label).value_with_matched_text_removed).to eq({
        :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis', :subspecies => [{:type => 'var.', :subspecies_epithet => 'occidua'}],
        :authorship => [{:author_names => ['Wheeler, W.M.'], :year => '1912c', :pages => '90'}]
      })
    end
  end

  describe "Order name" do
    it "should match an order name" do
      expect(@grammar.parse('Hymenoptera', :root => :order_name).value_with_matched_text_removed).to eq({:order_name => 'Hymenoptera'})
    end
  end

  describe "Family or order name" do
    it "should match an order name" do
      expect(@grammar.parse('Hymenoptera', :root => :order_or_family_name).value_with_matched_text_removed).to eq({:order_name => 'Hymenoptera'})
    end
    it "should match a family name" do
      expect(@grammar.parse('Formicidae', :root => :order_or_family_name).value_with_matched_text_removed).to eq({:family_name => 'Formicidae'})
    end
    it "should not think a family name that starts with an order name prefix is an order" do
      expect(@grammar.parse('Leptanillae', :root => :order_or_family_name).value_with_matched_text_removed).to eq({:family_name => 'Leptanillae'})
    end
    it "should not think a family name that starts with an order name prefix is an order" do
      expect(@grammar.parse('Leptanillae', :root => :order_or_family_name).value_with_matched_text_removed).to eq({:family_name => 'Leptanillae'})
    end
  end

  describe "Family/order name exceptions" do
    ['Colombia', 'Panama'].each do |name|
      it "should not consider '#{name}' an order/family name" do
        expect {@grammar.parse(name, :root => :order_or_family_name)}.to raise_error(Citrus::ParseError)
      end
    end
  end
  it "should not think a tribe name that starts with a family name prefix is a family" do
    expect(@grammar.parse('Palaeoitini', :root => :family_group_name).value_with_matched_text_removed).to eq({:tribe_name => 'Palaeoitini'})
  end

  describe "Myrmiciidae (Symphyta)" do
    it "should parse it" do
      expect(@grammar.parse('*Myrmiciidae (Symphyta)', :root => :family_or_subfamily_label).value_with_matched_text_removed).to eq({:family_name => 'Myrmiciidae', :fossil => true, :suborder_name => 'Symphyta'})
    end
  end

  describe "Family-group names" do
    it "should parse a family name" do
      expect(@grammar.parse('Formicidae', :root => :family_name).value_with_matched_text_removed).to eq({:family_name => 'Formicidae'})
    end
    it "should parse a subfamily name" do
      expect(@grammar.parse('Ectatomminae', :root => :subfamily_name).value_with_matched_text_removed).to eq({:subfamily_name => 'Ectatomminae'})
    end
    it "should parse an uppercase subfamily name" do
      expect(@grammar.parse('FORMICIDAE', :root => :family_name_uppercase).value_with_matched_text_removed).to eq({:family_name => 'Formicidae'})
    end
    it "should parse a family label" do
      expect(@grammar.parse('*Formicidae', :root => :family_label).value_with_matched_text_removed).to eq({:family_name => 'Formicidae', :fossil => true})
    end
    it "should parse a subfamily label" do
      expect(@grammar.parse('*Ectatomminae', :root => :family_label).value_with_matched_text_removed).to eq({:family_name => 'Ectatomminae', :fossil => true})
    end
    it "should parse a subfamily label" do
      expect(@grammar.parse('*Ectatomminae', :root => :family_label).value_with_matched_text_removed).to eq({:family_name => 'Ectatomminae', :fossil => true})
    end
    describe "Family-group name" do
      it "should accept a family or subfamily name" do
        expect(@grammar.parse('Ectatomminae', :root => :family_group_name).value_with_matched_text_removed).to eq({:family_or_subfamily_name => 'Ectatomminae'})
      end
      it "should accept a tribe name" do
        expect(@grammar.parse('Ectatommini', :root => :family_group_name).value_with_matched_text_removed).to eq({:tribe_name => 'Ectatommini'})
      end
      it "should accept a tribe name ending in -ii" do
        expect(@grammar.parse('Dimorphomyrmii', :root => :family_group_name).value_with_matched_text_removed).to eq({:tribe_name => 'Dimorphomyrmii'})
      end
      it "should accept a subtribe name" do
        expect(@grammar.parse('Bothriomyrmecina', :root => :family_group_name).value_with_matched_text_removed).to eq({:subtribe_name => 'Bothriomyrmecina'})
      end
      it "should accept a subtribe name ending in -iti" do
        expect(@grammar.parse('Dacetiti', :root => :family_group_name).value_with_matched_text_removed).to eq({:subtribe_name => 'Dacetiti'})
      end
      it "should not accept a species name" do
        expect {@grammar.parse('afar', :root => :family_group_name)}.to raise_error
      end
    end
  end

  describe "Tribe" do
    describe "Names" do
      it "should parse a tribe" do
        expect(@grammar.parse('Ectatommini', :root => :tribe_name).value_with_matched_text_removed).to eq({:tribe_name => 'Ectatommini'})
      end
      it "should parse a tribe that ends in -ii" do
        expect(@grammar.parse('Plagiolepisii', :root => :tribe_name).value_with_matched_text_removed).to eq({:tribe_name => 'Plagiolepisii'})
      end
      it "should parse a subtribe that ends in -ina" do
        expect(@grammar.parse('Bothriomyrmecina', :root => :subtribe_name).value_with_matched_text_removed).to eq({:subtribe_name => 'Bothriomyrmecina'})
      end
      it "should handle this special case" do
        expect(@grammar.parse('Platythyrei', :root => :tribe_name).value_with_matched_text_removed).to eq({:tribe_name => 'Platythyrei'})
      end
    end

    describe "Labels" do
      it "should parse a tribe label" do
        expect(@grammar.parse('*Ectatommini Wheeler, 2002a: 66', :root => :tribe_label).value_with_matched_text_removed).to eq(
          {:tribe_name => 'Ectatommini', :fossil => true, :authorship => [{:author_names => ['Wheeler'], :year => '2002a', :pages => '66'}]}
        )
      end
      it "should parse a very simple tribe label" do
        expect(@grammar.parse('Platythyreini', :root => :tribe_label).value_with_matched_text_removed).to eq({:tribe_name => 'Platythyreini'})
      end
      it "should parse a tribe label with 'sice'" do
        expect(@grammar.parse('*Ectatommini (<i>sic</i>) Wheeler, 2002a: 66', :root => :tribe_label).value_with_matched_text_removed).to eq(
          {:tribe_name => 'Ectatommini', :sic => true, :fossil => true, :authorship => [{:author_names => ['Wheeler'], :year => '2002a', :pages => '66'}]}
        )
      end
      it "should parse a subtribe label" do
        expect(@grammar.parse('Bothriomyrmecina Dubovikov, 2005a: 92', :root => :subtribe_label).value_with_matched_text_removed).to eq(
          {:subtribe_name => 'Bothriomyrmecina', :authorship => [{:author_names => ['Dubovikov'], :year => '2005a', :pages => '92'}]}
        )
      end
    end
  end
  describe "Genus-group names" do
    it "should parse a genus" do
      expect(@grammar.parse('Ectatomma', :root => :genus_name).value_with_matched_text_removed).to eq({:genus_name => 'Ectatomma'})
    end
    it "should parse a subgenus epithet" do
      expect(@grammar.parse('Ectatommus', :root => :subgenus_epithet).value_with_matched_text_removed).to eq({:subgenus_epithet => 'Ectatommus'})
    end
    it "should parse a full subgenus name" do
      expect(@grammar.parse('Ectatomma (Ectatommus)', :root => :subgenus_name).value_with_matched_text_removed).to eq({:genus_name => 'Ectatomma', :subgenus_epithet => 'Ectatommus'})
    end
    it "should parse a full subgenus name when the genus is abbreviated" do
      expect(@grammar.parse('E. (Ectatommus)', :root => :subgenus_name).value_with_matched_text_removed).to eq({:genus_abbreviation => 'E.', :subgenus_epithet => 'Ectatommus'})
    end

    describe "Genus-group labels" do
      it "should parse a genus label" do
        expect(@grammar.parse('*<i>Ectatomma</i>', :root => :genus_label).value_with_matched_text_removed).to eq({:genus_name => 'Ectatomma', :fossil => true})
      end
      it "should parse a full subgenus label" do
        expect(@grammar.parse('*<i>Ectatomma (Ectatommus)</i> Bolton, 2000: 1', :root => :subgenus_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Ectatomma', :subgenus_epithet => 'Ectatommus', :fossil => true,
          :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]})
      end
      it "should parse a subgenus label with abbreviated genus" do
        expect(@grammar.parse('*<i>E. (Ectatommus)</i> Bolton, 2000: 1', :root => :subgenus_label).value_with_matched_text_removed).to eq({
          :genus_abbreviation => 'E.', :subgenus_epithet => 'Ectatommus', :fossil => true,
          :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]})
      end
      it "should parse a genus_label with authorship" do
        expect(@grammar.parse('*<i>Ectatomma</i> Forel, 1944: 23', :root => :genus_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Ectatomma', :fossil => true, :authorship => [{:author_names => ['Forel'], :year => '1944', :pages => '23'
        }]})
      end
      it "should parse a fossil subgenus label where the subgenus is a fossil but the genus is not" do
        expect(@grammar.parse('<i>Aphaenogaster (*Sinaphaenogaster)</i>', :root => :subgenus_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Aphaenogaster', :subgenus_epithet => 'Sinaphaenogaster', :fossil => true
        })
      end
      it "should parse an uppercase genus label" do
        expect(@grammar.parse('<i>APHAENOGASTER</i>', :root => :genus_label_uppercase).value_with_matched_text_removed).to eq({
          :genus_name => 'Aphaenogaster'
        })
      end
    end
  end

  describe "Collective group label" do
    it "should parse a collective group label" do
      expect(@grammar.parse('*<i>Formicites</i> (collective group name)', root: :collective_group_label, consume: false).value_with_matched_text_removed).to eq({collective_group_name: 'Formicites', fossil: true})
    end
    it "should parse an uppercase collective group name label" do
      expect(@grammar.parse(%{*<i>MYRMICITES</i>}, :root => :collective_group_label_uppercase).value_with_matched_text_removed).to eq({
        :collective_group_name => 'Myrmicites', :fossil => true
      })
    end
  end

  describe "Question marks" do
    it "should ignore them" do
      expect(@grammar.parse('<i>Myrmeciites (?) tabanifluviensis</i>', root: :species_label).value_with_matched_text_removed).to eq({
        genus_name: 'Myrmeciites', species_epithet: 'tabanifluviensis'
      })
    end
  end

  describe "Species-group names" do
    describe "Species epithet" do
      it "should parse a species epithet" do
        expect(@grammar.parse('macrops', :root => :species_epithet).value_with_matched_text_removed).to eq({:species_epithet => 'macrops'})
      end
      it "should not allow a space" do
        expect {@grammar.parse('chilensis negrescens', :root => :species_epithet)}.to raise_error(Citrus::ParseError)
      end
      it "should allow a hyphen in the second position" do
        expect(@grammar.parse('v-nigra', :root => :species_epithet)).not_to be_nil
      end
      it "should not allow a hyphen in the first position" do
        expect {@grammar.parse('-vnigra', :root => :species_epithet)}.to raise_error
      end
      it "should not allow a hyphen in the third position" do
        expect {@grammar.parse('vn-igra', :root => :species_epithet)}.to raise_error
      end
      it "can have only two letters" do
        expect(@grammar.parse('io', :root => :species_epithet)).not_to be_nil
      end
    end

    describe "Subspecies epithet" do
      it "should parse a subspecies epithet" do
        expect(@grammar.parse('rufa', :root => :subspecies_epithet).value_with_matched_text_removed).to eq({:subspecies_epithet => 'rufa'})
      end
    end

    describe "Species-group epithet label" do
      it "should parse a species epithet label" do
        expect(@grammar.parse('<i>macrops</i>', :root => :species_epithet_label).value_with_matched_text_removed).to eq({:species_epithet => 'macrops'})
      end
      it "should parse a species epithet label with authorship" do
        expect(@grammar.parse('<i>macrops</i> Forel', :root => :species_epithet_label).value_with_matched_text_removed).to eq({
          :species_epithet => 'macrops', :authorship => [{:author_names => ['Forel']
        }]})
      end
      it "should parse a fossil species epithet label" do
        expect(@grammar.parse('*<i>macrops</i>', :root => :species_epithet_label).value_with_matched_text_removed).to eq({:species_epithet => 'macrops', :fossil => true})
      end
      it "should parse a fossil subspecies and return the status" do
        expect(@grammar.parse('*<i>rufa</i>', :root => :subspecies_epithet_label).value_with_matched_text_removed).to eq({:subspecies_epithet => 'rufa', :fossil => true})
      end
      it "should parse a subspecies with authorship" do
        expect(@grammar.parse('*<i>rufa</i> Bolton, 2000: 1', :root => :subspecies_epithet_label).value_with_matched_text_removed).to eq({
          :subspecies_epithet => 'rufa', :fossil => true, :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]})
      end
    end

    describe "Species label" do
      it "should parse a simple genus + species" do
        expect(@grammar.parse("<i>Furcisutura wanghuacunensis</i>", :root => :species_label).value_with_matched_text_removed).to eq(
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis'}
        )
      end
      it "should parse a simple genus + species with authorship" do
        expect(@grammar.parse("<i>Furcisutura wanghuacunensis</i> Forel, 2000a: 23", :root => :species_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis',
          :authorship => [{:author_names => ['Forel'], :year => '2000a', :pages => '23'
        }]})
      end
      it "should parse a fossil genus + species" do
        expect(@grammar.parse("*<i>Furcisutura wanghuacunensis</i>", :root => :species_label).value_with_matched_text_removed).to eq(
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis', :fossil => true}
        )
      end
      it "should parse an abbreviated genus + species + subspecies" do
        expect(@grammar.parse("<i>F. rufibarbis</i> var. <i>minor</i>", :root => :subspecies_label).value_with_matched_text_removed).to eq({
          :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis',
          :subspecies => [{:type => 'var.', :subspecies_epithet => 'minor'}]
        })
      end
      it "should parse a genus + subgenus + species" do
        expect(@grammar.parse("<i>Formica (Forma) rufibarbis</i>", :root => :species_label).value_with_matched_text_removed).to eq(
          {:genus_name => 'Formica', :subgenus_epithet => 'Forma', :species_epithet => 'rufibarbis'}
        )
      end
    end

    describe "Species name" do
      it "should parse a simple genus + species" do
        expect(@grammar.parse("Furcisutura wanghuacunensis", :root => :species_name).value_with_matched_text_removed).to eq(
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis'}
        )
      end
    end

    describe "Subspecies label" do
      it "should parse genus + subgenus, species & multiple subspecies" do
        expect(@grammar.parse("*<i>Furcisutura (Atturus) wanghuacunensis</i> var. <i>rufa</i> st. <i>minor</i>", :root => :subspecies_label).value_with_matched_text_removed).to eq(
          {:genus_name => 'Furcisutura', :subgenus_epithet => 'Atturus', :species_epithet => 'wanghuacunensis', :subspecies => [
            {:type => 'var.', :subspecies_epithet => 'rufa'}, {:type => 'st.', :subspecies_epithet => 'minor'}
          ], :fossil => true}
        )
      end

      it "should parse one long italicized string" do
        expect(@grammar.parse('<i>Atta afar minor</i>', :root => :subspecies_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [:subspecies_epithet => 'minor']
        })
      end

      it "should parse one long italicized string with authorship" do
        expect(@grammar.parse('<i>Atta afar minor</i> Forel', :root => :subspecies_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [:subspecies_epithet => 'minor'],
          :authorship => [{:author_names => ['Forel']
        }]})
      end

      it "matches a subspecies label with an abbreviated genus" do
        expect(@grammar.parse('<i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90', :root => :subspecies_label).value_with_matched_text_removed).to eq({
          :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis', :subspecies => [{:type => 'var.', :subspecies_epithet => 'occidua'}],
          :authorship => [{:author_names => ['Wheeler, W.M.'], :year => '1912c', :pages => '90'
        }]})
      end

      it "should parse genus + subgenus, species & multiple subspecies with an authorship" do
        expect(@grammar.parse("*<i>Furcisutura (Atturus) wanghuacunensis</i> var. <i>rufa</i> st. <i>minor</i> Forel, 1923a: 344", :root => :subspecies_label).value_with_matched_text_removed).to eq({
          :genus_name => 'Furcisutura', :subgenus_epithet => 'Atturus', :species_epithet => 'wanghuacunensis',
          :subspecies => [{:type => 'var.', :subspecies_epithet => 'rufa'}, {:type => 'st.', :subspecies_epithet => 'minor'}],
          :fossil => true, :authorship => [{:author_names => ['Forel'], :year => '1923a', :pages => '344'
        }]})
      end
    end

  end
end
