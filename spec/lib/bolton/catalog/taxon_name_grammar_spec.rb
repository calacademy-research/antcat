# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Grammar do
  before do
    @grammar = Bolton::Catalog::Grammar
  end

  describe "Taxon label" do
    it "matches an order name" do
      @grammar.parse('Homoptera', :root => :taxon_label).value.should == {:order_name => 'Homoptera'}
    end
    it "matches a family name" do
      @grammar.parse('Formicidae', :root => :taxon_label).value.should == {:family_or_subfamily_name => 'Formicidae'}
    end
    it "matches a subfamily name" do
      @grammar.parse('Myrmicinae', :root => :taxon_label).value.should == {:family_or_subfamily_name => 'Myrmicinae'}
    end
    it "matches a tribe name" do
      @grammar.parse('Bothriomyrmecini', :root => :taxon_label).value.should == {:tribe_name => 'Bothriomyrmecini'}
    end
    it "matches this weird tribe name" do
      @grammar.parse('Platythyreini', :root => :taxon_label).value.should == {:tribe_name => 'Platythyreini'}
    end
    it "matches a subtribe name" do
      @grammar.parse('Bothriomyrmecina', :root => :taxon_label).value.should == {:subtribe_name => 'Bothriomyrmecina'}
    end
    it "matches a genus label" do
      @grammar.parse('*<i>Atta</i>', :root => :taxon_label).value.should == {:genus_name => 'Atta', :fossil => true}
    end
    it "matches a genus + subgenus label" do
      @grammar.parse('<i>Atta (Atturus)</i>', :root => :taxon_label).value.should == {:genus_name => 'Atta', :subgenus_epithet => 'Atturus'}
    end
    it "matches an abbreviated genus + subgenus label" do
      @grammar.parse('<i>A. (Atturus)</i>', :root => :taxon_label).value.should == {:genus_abbreviation => 'A.', :subgenus_epithet => 'Atturus'}
    end
    it "should parse a collective group label" do
      @grammar.parse('*<i>Formicites</i> (collective group name)', :root => :taxon_label).value.should == {:collective_group_name => 'Formicites', :fossil => true}
    end
    it "matches a species-group epithet label" do
      @grammar.parse('<i>afar</i>', :root => :taxon_label).value.should == {:species_group_epithet => 'afar'}
    end
    it "matches a species label" do
      @grammar.parse('<i>Atta (Atturus) afar</i>', :root => :taxon_label).value.should ==
        {:genus_name => 'Atta', :subgenus_epithet => 'Atturus', :species_epithet => 'afar'}
    end
    it "matches a subspecies label" do
      @grammar.parse('<i>Atta afar minor</i>', :root => :taxon_label).value.should ==
        {:genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [{:subspecies_epithet => 'minor'}]}
    end
    it "matches a subspecies label with an abbreviated genus" do
      @grammar.parse('<i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90', :root => :taxon_label).value.should == {
        :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis', :subspecies => [{:type => 'var.', :subspecies_epithet => 'occidua'}],
        :authorship => [{:author_names => ['Wheeler, W.M.'], :year => '1912c', :pages => '90'}]
      }
    end
  end

  describe "Order name" do
    it "should match an order name" do
      @grammar.parse('Hymenoptera', :root => :order_name).value.should == {:order_name => 'Hymenoptera'}
    end
  end

  describe "Family or order name" do
    it "should match an order name" do
      @grammar.parse('Hymenoptera', :root => :order_or_family_name).value.should == {:order_name => 'Hymenoptera'}
    end
    it "should match a family name" do
      @grammar.parse('Formicidae', :root => :order_or_family_name).value.should == {:family_name => 'Formicidae'}
    end
    it "should not think a family name that starts with an order name prefix is an order" do
      @grammar.parse('Leptanillae', :root => :order_or_family_name).value.should == {:family_name => 'Leptanillae'}
    end
    it "should not think a family name that starts with an order name prefix is an order" do
      @grammar.parse('Leptanillae', :root => :order_or_family_name).value.should == {:family_name => 'Leptanillae'}
    end
  end

  describe "Family/order name exceptions" do
    ['Colombia', 'Panama'].each do |name|
      it "should not consider '#{name}' an order/family name" do
        lambda {@grammar.parse(name, :root => :order_or_family_name)}.should raise_error(Citrus::ParseError)
      end
    end
  end
  it "should not think a tribe name that starts with a family name prefix is a family" do
    @grammar.parse('Palaeoitini', :root => :family_group_name).value.should == {:tribe_name => 'Palaeoitini'}
  end

  describe "Myrmiciidae (Symphyta)" do
    it "should parse it" do
      @grammar.parse('*Myrmiciidae (Symphyta)', :root => :family_or_subfamily_label).value.should == {:family_name => 'Myrmiciidae', :fossil => true, :suborder => 'Symphyta'}
    end
  end

  describe "Family-group names" do
    it "should parse a family name" do
      @grammar.parse('Formicidae', :root => :family_name).value.should == {:family_name => 'Formicidae'}
    end
    it "should parse a subfamily name" do
      @grammar.parse('Ectatomminae', :root => :subfamily_name).value.should == {:subfamily_name => 'Ectatomminae'}
    end
    it "should parse an uppercase subfamily name" do
      @grammar.parse('FORMICIDAE', :root => :family_name_uppercase).value.should == {:family_name => 'Formicidae'}
    end
    it "should parse a family label" do
      @grammar.parse('*Formicidae', :root => :family_label).value.should == {:family_name => 'Formicidae', :fossil => true}
    end
    it "should parse a subfamily label" do
      @grammar.parse('*Ectatomminae', :root => :family_label).value.should == {:family_name => 'Ectatomminae', :fossil => true}
    end
    it "should parse a subfamily label" do
      @grammar.parse('*Ectatomminae', :root => :family_label).value.should == {:family_name => 'Ectatomminae', :fossil => true}
    end
    describe "Family-group name" do
      it "should accept a family or subfamily name" do
        @grammar.parse('Ectatomminae', :root => :family_group_name).value.should == {:family_or_subfamily_name => 'Ectatomminae'}
      end
      it "should accept a tribe name" do
        @grammar.parse('Ectatommini', :root => :family_group_name).value.should == {:tribe_name => 'Ectatommini'}
      end
      it "should accept a subtribe name" do
        @grammar.parse('Bothriomyrmecina', :root => :family_group_name).value.should == {:subtribe_name => 'Bothriomyrmecina'}
      end
      it "should accept a subtribe name ending in -iti" do
        @grammar.parse('Dacetiti', :root => :family_group_name).value.should == {:subtribe_name => 'Dacetiti'}
      end
      it "should not accept a species name" do
        lambda {@grammar.parse('afar', :root => :family_group_name)}.should raise_error
      end
    end
  end

  describe "Tribe" do
    describe "Names" do
      it "should parse a tribe" do
        @grammar.parse('Ectatommini', :root => :tribe_name).value.should == {:tribe_name => 'Ectatommini'}
      end
      it "should parse a tribe that ends in -ii" do
        @grammar.parse('Plagiolepisii', :root => :tribe_name).value.should == {:tribe_name => 'Plagiolepisii'}
      end
      it "should parse a subtribe that ends in -ina" do
        @grammar.parse('Bothriomyrmecina', :root => :subtribe_name).value.should == {:subtribe_name => 'Bothriomyrmecina'}
      end
      it "should handle this special case" do
        @grammar.parse('Platythyrei', :root => :tribe_name).value.should == {:tribe_name => 'Platythyrei'}
      end
    end

    describe "Labels" do
      it "should parse a tribe label" do
        @grammar.parse('*Ectatommini Wheeler, 2002a: 66', :root => :tribe_label).value.should ==
          {:tribe_name => 'Ectatommini', :fossil => true, :authorship => [{:author_names => ['Wheeler'], :year => '2002a', :pages => '66'}]}
      end
      it "should parse a very simple tribe label" do
        @grammar.parse('Platythyreini', :root => :tribe_label).value.should == {:tribe_name => 'Platythyreini'}
      end
      it "should parse a tribe label with 'sice'" do
        @grammar.parse('*Ectatommini (<i>sic</i>) Wheeler, 2002a: 66', :root => :tribe_label).value.should ==
          {:tribe_name => 'Ectatommini', :sic => true, :fossil => true, :authorship => [{:author_names => ['Wheeler'], :year => '2002a', :pages => '66'}]}
      end
      it "should parse a subtribe label" do
        @grammar.parse('Bothriomyrmecina Dubovikov, 2005a: 92', :root => :subtribe_label).value.should ==
          {:subtribe_name => 'Bothriomyrmecina', :authorship => [{:author_names => ['Dubovikov'], :year => '2005a', :pages => '92'}]}
      end
    end
  end
  describe "Genus-group names" do
    it "should parse a genus" do
      @grammar.parse('Ectatomma', :root => :genus_name).value.should == {:genus_name => 'Ectatomma'}
    end
    it "should parse a subgenus epithet" do
      @grammar.parse('Ectatommus', :root => :subgenus_epithet).value.should == {:subgenus_epithet => 'Ectatommus'}
    end
    it "should parse a full subgenus name" do
      @grammar.parse('Ectatomma (Ectatommus)', :root => :subgenus_name).value.should == {:genus_name => 'Ectatomma', :subgenus_epithet => 'Ectatommus'}
    end
    it "should parse a full subgenus name when the genus is abbreviated" do
      @grammar.parse('E. (Ectatommus)', :root => :subgenus_name).value.should == {:genus_abbreviation => 'E.', :subgenus_epithet => 'Ectatommus'}
    end

    describe "Genus-group labels" do
      it "should parse a genus label" do
        @grammar.parse('*<i>Ectatomma</i>', :root => :genus_label).value.should == {:genus_name => 'Ectatomma', :fossil => true}
      end
      it "should parse a full subgenus label" do
        @grammar.parse('*<i>Ectatomma (Ectatommus)</i> Bolton, 2000: 1', :root => :subgenus_label).value.should == {
          :genus_name => 'Ectatomma', :subgenus_epithet => 'Ectatommus', :fossil => true,
          :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]}
      end
      it "should parse a subgenus label with abbreviated genus" do
        @grammar.parse('*<i>E. (Ectatommus)</i> Bolton, 2000: 1', :root => :subgenus_label).value.should == {
          :genus_abbreviation => 'E.', :subgenus_epithet => 'Ectatommus', :fossil => true,
          :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]}
      end
      it "should parse a genus_label with authorship" do
        @grammar.parse('*<i>Ectatomma</i> Forel, 1944: 23', :root => :genus_label).value.should == {
          :genus_name => 'Ectatomma', :fossil => true, :authorship => [{:author_names => ['Forel'], :year => '1944', :pages => '23'
        }]}
      end
      it "should parse a fossil subgenus label where the subgenus is a fossil but the genus is not" do
        @grammar.parse('<i>Aphaenogaster (*Sinaphaenogaster)</i>', :root => :subgenus_label).value.should == {
          :genus_name => 'Aphaenogaster', :subgenus_epithet => 'Sinaphaenogaster', :fossil => true
        }
      end
      it "should parse an uppercase genus label" do
        @grammar.parse('<i>APHAENOGASTER</i>', :root => :genus_label_uppercase).value.should == {
          :genus_name => 'Aphaenogaster'
        }
      end
    end
  end

  describe "Collective group label" do
    it "should parse a collective group label" do
      @grammar.parse('*<i>Formicites</i> (collective group name)', :root => :collective_group_label).value.should == {:collective_group_name => 'Formicites', :fossil => true}
    end
    it "should parse an uppercase collective group name label" do
      @grammar.parse(%{*<i>MYRMICITES</i>}, :root => :collective_group_label_uppercase).value.should == {
        :collective_group_name => 'Myrmicites', :fossil => true
      }
    end
  end

  describe "Species-group names" do
    describe "Species epithet" do
      it "should parse a species epithet" do
        @grammar.parse('macrops', :root => :species_epithet).value.should == {:species_epithet => 'macrops'}
      end
      it "should not allow a space" do
        lambda {@grammar.parse('chilensis negrescens', :root => :species_epithet)}.should raise_error(Citrus::ParseError)
      end
      it "should allow a hyphen in the second position" do
        @grammar.parse('v-nigra', :root => :species_epithet).should_not be_nil
      end
      it "should not allow a hyphen in the first position" do
        lambda {@grammar.parse('-vnigra', :root => :species_epithet)}.should raise_error
      end
      it "should not allow a hyphen in the third position" do
        lambda {@grammar.parse('vn-igra', :root => :species_epithet)}.should raise_error
      end
      it "can have only two letters" do
        @grammar.parse('io', :root => :species_epithet).should_not be_nil
      end
    end

    describe "Subspecies epithet" do
      it "should parse a subspecies epithet" do
        @grammar.parse('rufa', :root => :subspecies_epithet).value.should == {:subspecies_epithet => 'rufa'}
      end
    end

    describe "Species-group epithet label" do
      it "should parse a species epithet label" do
        @grammar.parse('<i>macrops</i>', :root => :species_epithet_label).value.should == {:species_epithet => 'macrops'}
      end
      it "should parse a species epithet label with authorship" do
        @grammar.parse('<i>macrops</i> Forel', :root => :species_epithet_label).value.should == {
          :species_epithet => 'macrops', :authorship => [{:author_names => ['Forel']
        }]}
      end
      it "should parse a fossil species epithet label" do
        @grammar.parse('*<i>macrops</i>', :root => :species_epithet_label).value.should == {:species_epithet => 'macrops', :fossil => true}
      end
      it "should parse a fossil subspecies and return the status" do
        @grammar.parse('*<i>rufa</i>', :root => :subspecies_epithet_label).value.should == {:subspecies_epithet => 'rufa', :fossil => true}
      end
      it "should parse a subspecies with authorship" do
        @grammar.parse('*<i>rufa</i> Bolton, 2000: 1', :root => :subspecies_epithet_label).value.should == {
          :subspecies_epithet => 'rufa', :fossil => true, :authorship => [{:author_names => ['Bolton'], :year => '2000', :pages => '1'}]}
      end
    end

    describe "Species label" do
      it "should parse a simple genus + species" do
        @grammar.parse("<i>Furcisutura wanghuacunensis</i>", :root => :species_label).value.should ==
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis'}
      end
      it "should parse a simple genus + species with authorship" do
        @grammar.parse("<i>Furcisutura wanghuacunensis</i> Forel, 2000a: 23", :root => :species_label).value.should == {
          :genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis',
          :authorship => [{:author_names => ['Forel'], :year => '2000a', :pages => '23'
        }]}
      end
      it "should parse a fossil genus + species" do
        @grammar.parse("*<i>Furcisutura wanghuacunensis</i>", :root => :species_label).value.should ==
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis', :fossil => true}
      end
      it "should parse an abbreviated genus + species + subspecies" do
        @grammar.parse("<i>F. rufibarbis</i> var. <i>minor</i>", :root => :subspecies_label).value.should == {
          :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis',
          :subspecies => [{:type => 'var.', :subspecies_epithet => 'minor'}]
        }
      end
      it "should parse a genus + subgenus + species" do
        @grammar.parse("<i>Formica (Forma) rufibarbis</i>", :root => :species_label).value.should ==
          {:genus_name => 'Formica', :subgenus_epithet => 'Forma', :species_epithet => 'rufibarbis'}
      end
    end

    describe "Species name" do
      it "should parse a simple genus + species" do
        @grammar.parse("Furcisutura wanghuacunensis", :root => :species_name).value.should ==
          {:genus_name => 'Furcisutura', :species_epithet => 'wanghuacunensis'}
      end
    end

    describe "Subspecies label" do
      it "should parse genus + subgenus, species & multiple subspecies" do
        @grammar.parse("*<i>Furcisutura (Atturus) wanghuacunensis</i> var. <i>rufa</i> st. <i>minor</i>", :root => :subspecies_label).value.should ==
          {:genus_name => 'Furcisutura', :subgenus_epithet => 'Atturus', :species_epithet => 'wanghuacunensis', :subspecies => [
            {:type => 'var.', :subspecies_epithet => 'rufa'}, {:type => 'st.', :subspecies_epithet => 'minor'}
          ], :fossil => true}
      end

      it "should parse one long italicized string" do
        @grammar.parse('<i>Atta afar minor</i>', :root => :subspecies_label).value.should == {
          :genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [:subspecies_epithet => 'minor']
        }
      end

      it "should parse one long italicized string with authorship" do
        @grammar.parse('<i>Atta afar minor</i> Forel', :root => :subspecies_label).value.should == {
          :genus_name => 'Atta', :species_epithet => 'afar', :subspecies => [:subspecies_epithet => 'minor'],
          :authorship => [{:author_names => ['Forel']
        }]}
      end

      it "matches a subspecies label with an abbreviated genus" do
        @grammar.parse('<i>F. rufibarbis</i> var. <i>occidua</i> Wheeler, W.M. 1912c: 90', :root => :subspecies_label).value.should == {
          :genus_abbreviation => 'F.', :species_epithet => 'rufibarbis', :subspecies => [{:type => 'var.', :subspecies_epithet => 'occidua'}],
          :authorship => [{:author_names => ['Wheeler, W.M.'], :year => '1912c', :pages => '90'
        }]}
      end

      it "should parse genus + subgenus, species & multiple subspecies with an authorship" do
        @grammar.parse("*<i>Furcisutura (Atturus) wanghuacunensis</i> var. <i>rufa</i> st. <i>minor</i> Forel, 1923a: 344", :root => :subspecies_label).value.should == {
          :genus_name => 'Furcisutura', :subgenus_epithet => 'Atturus', :species_epithet => 'wanghuacunensis',
          :subspecies => [{:type => 'var.', :subspecies_epithet => 'rufa'}, {:type => 'st.', :subspecies_epithet => 'minor'}],
          :fossil => true, :authorship => [{:author_names => ['Forel'], :year => '1923a', :pages => '344'
        }]}
      end
    end

  end
end
