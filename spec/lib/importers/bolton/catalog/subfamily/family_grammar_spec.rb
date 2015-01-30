# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::FamilyGrammar do
  before do
    @grammar = Importers::Bolton::Catalog::Subfamily::FamilyGrammar
  end

  describe "Family-group headline" do
    it "should recognize a family group headline" do
      expect(@grammar.parse(%{Formicariae Latreille, 1809: 124. Type-genus: <i>Formica</i>.}).value_with_matched_text_removed).to eq({
        :type => :family_group_headline,
        :protonym => {
          :family_or_subfamily_name => 'Formicariae',
          :authorship => [{:author_names => ['Latreille'], :year => '1809', :pages => '124'}],
        },
        :type_genus => {:genus_name => 'Formica'}
      })
    end
    it "should recognize a family group headline for Myrmicites" do
      expect(@grammar.parse(%{Myrmicites Lepeletier de Saint-Fargeau, 1835: 169. Type-genus: <i>Myrmica</i>.}).value_with_matched_text_removed).to eq({
        type: :family_group_headline,
        protonym: {
          genus_name: 'Myrmicites',
          authorship: [{author_names: ['Lepeletier de Saint-Fargeau'], year: '1835', pages: '169'}],
        },
        type_genus: {genus_name: 'Myrmica'}
      })
    end
    it "should handle this non -ae taxon name" do
      @grammar.parse('Dorylida Leach, 1815: 147. Type-genus: <i>Dorylus</i>.').value
    end
    it "should handle this non -ae taxon name" do
      @grammar.parse('Dorylida', :root => :family_group_name).value
    end

  end

  describe "Family-group protonym" do
    it "should recognize a family protonym" do
      expect(@grammar.parse(%{*Formicariae Latreille, 1809: 124}, :root => :family_group_protonym).value_with_matched_text_removed).to eq({
        :family_or_subfamily_name => 'Formicariae', :fossil => true,
        :authorship => [{:author_names => ['Latreille'], :year => '1809', :pages => '124'}],
      })
    end
    it "should recognize a family protonym for a tribe" do
      @grammar.parse(%{Neoattini Kusnezov, 1956: 22}, :root => :family_group_protonym).value
    end
    it "should recognize a family protonym for a genus" do
      expect(@grammar.parse(%{Ponerites Kusnezov, 1956: 22}, :root => :family_group_protonym).value[:genus_name]).to eq('Ponerites')
    end
    it "should recognize a family protonym for a subtribe" do
      expect(@grammar.parse(%{Bothriomyrmecina Dubovikov, 2005a: 92}, :root => :family_group_protonym).value_with_matched_text_removed).to eq({
        :subtribe_name => 'Bothriomyrmecina',
        :authorship => [{:author_names => ['Dubovikov'], :year => '2005a', :pages => '92'}],
      })
    end
  end

  it "should recognize the family taxonomic history" do
    expect(@grammar.parse(%{Formicidae as family: Latreille, 1809: 124 [Formicariae]; Stephens, 1829: 356; all subsequent authors.}).value_with_matched_text_removed).to eq({
      :type => :family_history,
      :items => [
        {:phrase => 'Formicidae as family', :delimiter => ': '},
        {:author_names => ['Latreille'], :year => '1809', :pages => '124', :delimiter => ' '},
        {:text => [
          {:opening_bracket => "["},
          {:family_or_subfamily_name => "Formicariae"},
          {:closing_bracket=> "]"},
        ], :delimiter => '; '},
        {:author_names => ['Stephens'], :year => '1829', :pages => '356', :delimiter => '; '},
        {:phrase => 'all subsequent authors'},
      ]
    })
  end

  it "should recognize the extant subfamilies list" do
    expect(@grammar.parse(%{Subfamilies of Formicidae (extant): Aenictinae, Myrmicinae.}).value).to eq(
      {:type => :extant_subfamilies_list, :subfamilies => [{:subfamily_name => 'Aenictinae'}, {:subfamily_name => 'Myrmicinae'}]}
    )
  end

  it "should recognize the extinct subfamilies list" do
    expect(@grammar.parse(%{Subfamilies of Formicidae (extinct): *Armaniinae, *Brownimeciinae.}).value).to eq(
      {:type => :extinct_subfamilies_list, :subfamilies => [{:subfamily_name => 'Armaniinae', :fossil => true}, {:subfamily_name => 'Brownimeciinae', :fossil => true}]}
    )
  end

  it "should recognize the extant genera incertae sedis list" do
    expect(@grammar.parse(%{Genera (extant) <i>incertae sedis</i> in Formicidae: <i>Condylodon</i>.}).value).to eq(
      {:type => :extant_genera_incertae_sedis_in_family_list, :genera => [{:genus_name => 'Condylodon'}]}
    )
  end

  it "should recognize the extinct genera incertae sedis list" do
    expect(@grammar.parse(%{Genera (extinct) <i>incertae sedis</i> in Formicidae: *<i>Condylodon</i>, <i>Hypochira</i>.}).value_with_matched_text_removed).to eq(
      {:type => :extinct_genera_incertae_sedis_in_family_list, :genera => [{:genus_name => 'Condylodon', :fossil => true}, {:genus_name => 'Hypochira'}]}
    )
  end

  it "should recognize the extant genera excluded from family list" do
    expect(@grammar.parse(%{Genera (extant) excluded from Formicidae: <i>Formila</i>.}).value).to eq(
      {:type => :extant_genera_excluded_from_family_list, :genera => [{:genus_name => 'Formila'}]}
    )
  end

  it "should recognize the extinct genera excluded from family list" do
    expect(@grammar.parse(%{Genera (extinct) excluded from Formicidae: *<i>Cariridris</i>, *<i>Cretacoformica</i>.}).value).to eq(
      {:type => :extinct_genera_excluded_from_family_list, :genera => [{:genus_name => 'Cariridris', :fossil => true}, {:genus_name => 'Cretacoformica', :fossil => true}]}
    )
  end

  it "should recognize the genus group nomina nuda in family list, even if one of them is a fossil" do
    expect(@grammar.parse(%{Genus-group <i>nomina nuda</i> in Formicidae: <i>Ancylognathus</i>, *<i>Hypopheidole</i>.}).value).to eq(
      {:type => :genus_group_nomina_nuda_in_family_list, :genera => [{:genus_name => 'Ancylognathus'}, {:genus_name => 'Hypopheidole', :fossil => true}]}
    )
  end

  describe "Unavailable family-group names" do
    it "should parse their header" do
      expect(@grammar.parse(%{ALLOFORMICINAE [unavailable name]}).value).to eq(
        {:type => :unavailable_family_group_name_header, :name => 'Alloformicinae'}
      )
    end
    it "should parse their header when a tribe" do
      expect(@grammar.parse(%{NEOATTINI [unavailable name]}).value).to eq(
        {:type => :unavailable_family_group_name_header, :name => 'Neoattini'}
      )
    end
    it "should parse the details" do
      expect(@grammar.parse(%{Alloformicinae Emery, 1925b: 9 [as "section" of Formicinae]. Section designated to include tribes Melophorini, Myrmelachistini and Plagiolepidini. Unavailable name; not based on genus rank taxon. Contained material referable to Formicinae: Bolton, 1994: 51.}, :root => :unavailable_family_group_name_detail).value_with_matched_text_removed).to eq({
        :type => :unavailable_family_group_name_detail,
        :protonym => {:family_or_subfamily_name => 'Alloformicinae', :authorship => [{
          :author_names => ['Emery'],
          :year => '1925b',
          :pages => '9',
          :notes => [[
            {:phrase => "as", :delimiter => ' '},
            {:phrase => '"section"', :delimiter => ' '},
            {:phrase => 'of', :delimiter => ' '},
            {:family_or_subfamily_name => 'Formicinae'},
            {:bracketed => true}
          ]]}],
        },
        :additional_notes => [
          {:text => [
            {:phrase => 'Section designated to include tribes', :delimiter => ' '},
            {:tribe_name => 'Melophorini'},
            {:phrase => ',', :delimiter => ' '},
            {:tribe_name => 'Myrmelachistini', :delimiter => ' '},
            {:phrase => 'and', :delimiter => ' '},
            {:tribe_name => 'Plagiolepidini'},
          ], text_suffix:'. ', text_prefix: ' '},
          {:text => [
            {:phrase => 'Unavailable name', :delimiter => '; '}, {:phrase => 'not based on genus rank taxon'}
          ], text_suffix: '. '},
          {:text => [
            {:phrase => 'Contained material referable to', :delimiter => ' '},
            {:family_or_subfamily_name => 'Formicinae', :delimiter => ': '},
            {:author_names => ['Bolton'], :year => '1994', :pages => '51'}
          ], text_suffix: '.'},
        ]
      })
    end
    it "should handle a tribe as well as a genus" do
      @grammar.parse(%{Neoattini Kusnezov, 1956: 22; Kusnezov, 1964: 62 [as subdivision of tribe Attini]. Designated to include all attine genera except <i>Apterostigma</i>, <i>Mycocepurus</i>, <i>Myrmicocrypta</i>. Unavailable name; not based on genus rank taxon. Contained material referable to Attini: Bolton, 2003: 265.}, :root => :unavailable_family_group_name_detail).value
    end

    it "should handle a colon after the taxon name (in other words, it's not a protonym)" do
      expect(@grammar.parse(%{Promyrmicinae: Forel, 1917: 240 [incorrect expansion of the above unavailable name to include tribes Metaponini and Pseudomyrmini]. Unavailable name.}, :root => :unavailable_family_group_name_detail).value_with_matched_text_removed).to eq({
        :type => :unavailable_family_group_name_detail,
        :family_or_subfamily_name => 'Promyrmicinae',
        :author_names => ['Forel'], :year => '1917', :pages => '240', :notes => [[
          {:phrase => 'incorrect expansion of the above unavailable name to include tribes', :delimiter => ' '},
          {:tribe_name => 'Metaponini', :delimiter => ' '},
          {:phrase => 'and', :delimiter => ' '},
          {:tribe_name => 'Pseudomyrmini'},
          {:bracketed => true}
        ]],
        :additional_notes => [
          {:text => [
            {:phrase => 'Unavailable name'}
          ], text_suffix:".", text_prefix:" "}
        ]
      })
    end

  end

end
