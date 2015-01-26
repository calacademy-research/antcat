# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::History do
  before do
    @klass = Importers::Bolton::Catalog::Species::History
  end

  it "should consider an empty history as valid" do
    for history in [nil, []]
      expect(@klass.new(history).status).to eq('valid')
    end
  end

  describe "Synonyms" do
    it "should recognize a synonym_of" do
      history = @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
      ])
      expect(history.status).to eq('synonym')
      expect(history.epithets).to eq(['ferox'])
    end
    it "should recognize a synonym_of even if it's not the first item in the history" do
      history = @klass.new([
        {combinations_in: [{genus_name:"Acanthostichus"}]},
        {synonym_ofs: [{species_epithet: 'ferox'}]},
      ])
      expect(history.status).to eq('synonym')
      expect(history.epithets).to eq(['ferox'])
    end
    it "should overrule synonymy with revival from synonymy" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {revived_from_synonymy: {}},
      ]).status).to eq('valid')
    end
    it "should overrule synonymy with raisal to species with revival from synonymy" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {raised_to_species: {revived_from_synonymy:true}},
      ]).status).to eq('valid')
    end
    it "should stop on 'first available replacement' and make it valid" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {text: [], matched_text: 'hence first available replacement name for'},
        {homonym_of: {primary_or_secondary: :primary, genus_name: 'Formice'}},
      ]).status).to eq('valid')
    end
    it "should stop on 'Replacement name for' and make it valid" do
      expect(@klass.new([
        {text: [], matched_text: ' Replacement name for <i>Acromyrmex gallardoi</i> Santschi, 1936d: 411.'},
        {text: [], matched_text: '[Junior secondary homonym of <i>Sericomyrmex gallardoi</i> Santschi, 1920d: 379.]'},
      ]).status).to eq('valid')
    end
    it "should overrule synonymy with raisal to species with revival from synonymy" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {raised_to_species: {revived_from_synonymy:true}},
      ]).status).to eq('valid')
    end
  end

  describe "Revival" do
    it "should recognize this text string" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {text: [], matched_text: ' Revived from synonymy, revived status as species and senior synonym of <i>australiae</i>: Kohout, 1988c: 430. '},
      ]).status).to eq('valid')
    end
    it "should overrule synonymy with revival from synonymy" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {revived_from_synonymy: {}},
      ]).status).to eq('valid')
    end
    it "should recognize revived as species" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {revived_status_as_species: {}},
      ]).status).to eq('valid')
    end
    it "should recognize revived as species" do
      expect(@klass.new([
  {:first_available_use_of=>
     {:genus_name=>"Formica",
      :species_epithet=>"exsecta",
      :subspecies=>
       [{:subspecies_epithet=>"pressilabris", :type=>"subsp."},
        {:subspecies_epithet=>"foreli", :type=>"var."}],
      :authorship=>
       [{:author_names=>["Emery"],
         :year=>"1909b",
         :pages=>"192",
         :matched_text=>"Emery, 1909b: 192"}]},
    :matched_text=>
     " [First available use of <i>Formica exsecta</i> subsp. <i>pressilabris</i> var. <i>foreli</i> Emery, 1909b: 192; unavailable name.]"},
   {:combinations_in=>
     [{:genus_abbreviation=>"F.",
       :subgenus_epithet=>"Coptoformica",
       :references=>
        [{:author_names=>["Müller"],
          :year=>"1923",
          :pages=>"146",
          :matched_text=>"Müller, 1923: 146"}]}],
    :matched_text=>
     " Combination in <i>F. (Coptoformica)</i>: Müller, 1923: 146."},
   {:subspecies_ofs=>
     [{:species=>{:species_epithet=>"pressilabris"},
       :references=>
        [{:author_names=>["Müller"],
          :year=>"1923",
          :pages=>"146",
          :matched_text=>"Müller, 1923: 146"}]}],
    :matched_text=>" Subspecies of <i>pressilabris</i>: Müller, 1923: 146."},
   {:revived_status_as_species=>
     {:references=>
       [{:author_names=>["Dlussky"],
         :year=>"1964",
         :pages=>"1033",
         :matched_text=>"Dlussky, 1964: 1033"},
        {:author_names=>["Bernard"],
         :year=>"1967",
         :pages=>"324",
         :matched_text=>"Bernard, 1967: 324"},
        {:author_names=>["Kutter"],
         :year=>"1977c",
         :pages=>"284",
         :matched_text=>"Kutter, 1977c: 284"}]},
    :matched_text=>
     " Revived status as species: Dlussky, 1964: 1033; Bernard, 1967: 324; Kutter, 1977c: 284."},
   {:synonym_ofs=>
     [{:species_epithet=>"pressilabris",
       :references=>
        [{:author_names=>["Arakelian"],
          :year=>"1994",
          :pages=>"97",
          :matched_text=>"Arakelian, 1994: 97"},
         {:author_names=>["Seifert"],
          :year=>"1994",
          :pages=>"41",
          :matched_text=>"Seifert, 1994: 41"}],
       :junior_or_senior=>:junior}],
    :matched_text=>
     " Junior synonym of <i>pressilabris</i>: Arakelian, 1994: 97; Seifert, 1994: 41."},
   {:revived_status_as_species=>
     {:references=>
       [{:author_names=>["Seifert"],
         :year=>"2000a",
         :pages=>"543",
         :matched_text=>"Seifert, 2000a: 543"}],
      :junior_synonyms=>
       [{:species_group_epithet=>"goesswaldi"},
        {:species_group_epithet=>"naefi"},
        {:species_group_epithet=>"tamarae"}]},
    :matched_text=>
     " Revived status as species and senior synonym of <i>goesswaldi</i>, <i>naefi</i>, <i>tamarae</i>: Seifert, 2000a: 543."}
      ]).status).to eq('valid')
    end

    it "should set anything thats a first available replacement name as a Species" do
      expect(@klass.new([{:text=> [], matched_text: " Junior synonym of <i>australis</i> Forel, 1900b: 68 [junior secondary homonym of <i>australis</i> Forel, 1895f: 422] and hence first available replacement name: Brown, 1975: 22."}
      ]).taxon_subclass).to eq(Species)
    end
  end

  it "should read 'currently subspecies of' in the text" do
    expect(@klass.new([
      {text: [], matched_text: " Currently subspecies of <i>adamsi</i> (as the latter name has priority over <i>whymperi</i>): Bolton, 1995b: 206."}
    ]).taxon_subclass).to eq(Subspecies)
  end

  it "should handle an unavailable name" do
    expect(@klass.new([{unavailable_name: true}]).status).to eq('unavailable')
  end

  it "should handle a nomen nudum" do
    expect(@klass.new([{nomen_nudum: true}]).status).to eq('nomen nudum')
  end

  it "should consider anything with a subspecies list to be valid" do
    expect(@klass.new([
      {synonym_ofs: [{species_epithet: 'ferox'}]},
      {subspecies: [{species_group_epithet: 'falcifer'}]},
    ]).status).to eq('valid')
  end

  describe "Unidentifiable taxa" do
    it "should handle explicit parse" do
      expect(@klass.new([{unidentifiable: true}]).status).to eq('unidentifiable')
    end
    it "should handle 'unidentifiable' in the text" do
      expect(@klass.new([{text: [], matched_text: 'Unidentifiable taxon'},]).status).to eq('unidentifiable')
    end
  end

  it "should handle 'homonym' in the text" do
    expect(@klass.new([{text: [], matched_text: '[Junior secondary homonym of <i>Cerapachys cooperi</i> Arnold, 1915: 14.]'}]).status).to eq('homonym')
  end

  describe "Unresolved homonyms" do
    it "should handle an unresolved homonym even if it's a current subspecies" do
      expect(@klass.new([
        {homonym_of: {:unresolved=>true}},
        {currently_subspecies_of: {}},
      ]).status).to eq('unresolved homonym')
    end
    it "should handle an unresolved homonym in text" do
      expect(@klass.new([{text: [], matched_text: ' [Unresolved junior primary homonym of <i>longiceps</i> Santschi, above (Bolton, 1995b: 156).]'},
      ]).status).to eq('unresolved homonym')
    end
  end

  it "should a taxon excluded from Formicidae" do
    expect(@klass.new([{text: [], matched_text: 'Excluded from Formicidae'}]).status).to eq('excluded from Formicidae')
  end

  it "should handle it when information is in matched_text" do
    expect(@klass.new([{text: [], matched_text: ' Unidentifiable taxon, <i>incertae sedis</i> in <i>Acromyrmex</i>: Kempf, 1972a: 16.'}]).status).to eq('unidentifiable')
  end

  it "should handle unnecessary replacement name in text" do
    history = @klass.new([{text: [], matched_text: ' Unnecessary replacement name for <i>Odontomachus tyrannicus</i> Smith, F. 1861b: 44 and hence junior synonym of <i>gladiator</i> Mayr, 1862: 712, the first available replacement name: Brown, 1978c: 556.'}])
    expect(history.status).to eq('synonym')
    expect(history.epithets).to eq(['gladiator'])
  end

  it "should handle both a first and second replacement name" do
    history = @klass.new([
      {homonym_of:
        {primary_or_secondary: :primary, species_epithet:'jacobsoni'},
       matched_text: " [Junior primary homonym of <i>jacobsoni</i> Forel, above.]"},
      {text: [], matched_text: " First replacement name: <i>menozzii</i> Donisthorpe, 1941k: 237. "},
      {text: [], matched_text: "Second (unnecessary) replacement name: <i>ineditus</i> Baroni Urbani, 1971b: 360."},
        ])
    expect(history.status).to eq('homonym')
    #history.epithets.should == ['menozzii']
  end

  it "shouldn't get confused by this" do
    history = @klass.new [
      {text: [
        {opening_bracket: '['}, {phrase: 'Junior secondary homonym of', delimiter: ' '}, {closing_bracket: ']'},
       ], matched_text:  ' [Junior secondary homonym of <i>macrocephala</i> Erichson, above.]'
      },
      {senior_synonym_ofs:  []},
      {text:  [
        {genus_abbreviation: 'C.', species_epithet: 'geralensis'},
        {phrase: 'oldest synonym and hence first available replacement name'},
       ], matched_text: ' [<i>clara</i> oldest synonym and hence first available replacement name.]'
      },
    ]
    expect(history.status).to eq('homonym')
  end

  it "should handle 'un' in the text" do
    expect(@klass.new([{text: [], matched_text: '[Junior secondary homonym of <i>Cerapachys cooperi</i> Arnold, 1915: 14.]'}]).status).to eq('homonym')
  end

  describe "Species that became valid after being invalid" do

    it "should handle becoming a species after being a subspecies and a synonym" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet:'minutum', junior_or_senior: :junior}]},
        {subspecies_ofs: [{species: {species_epithet: 'minutum'}}]},
        {status_as_species: {references: []}},
      ]).status).to eq('valid')
    end

    it "should handle being revived and raised" do
      expect(@klass.new([
        {subspecies_ofs: [{species: {species_epithet: 'minutum'}}]},
        {revived_from_synonymy: {raised_to_species: true}},
      ]).status).to eq('valid')
    end

  end

  describe "Determining whether it's a species or a subspecies by looking at history" do
    it "should return nil if the history doesn't help" do
      expect(@klass.new([{synonym_ofs: [{species_epithet:'minutum', junior_or_senior: :junior}]}]).taxon_subclass).to be_nil
    end
    it "should handle becoming a species after being a subspecies and a synonym" do
      expect(@klass.new([
        {synonym_ofs: [{species_epithet:'minutum', junior_or_senior: :junior}]},
        {subspecies_ofs: [{species: {species_epithet: 'minutum'}}]},
        {status_as_species: {references: []}},
      ]).taxon_subclass).to eq(Species)
    end
  end

end
