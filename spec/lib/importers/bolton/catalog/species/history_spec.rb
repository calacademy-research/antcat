# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::History do
  before do
    @klass = Importers::Bolton::Catalog::Species::History
  end

  it "should consider an empty history as valid" do
    for history in [nil, []]
      @klass.new(history).status.should == 'valid'
    end
  end

  describe "Synonyms" do
    it "should recognize a synonym_of" do
      history = @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
      ])
      history.status.should == 'synonym'
      history.epithet.should == 'ferox'
    end
    it "should recognize a synonym_of even if it's not the first item in the history" do
      history = @klass.new([
        {combinations_in: [{genus_name:"Acanthostichus"}]},
        {synonym_ofs: [{species_epithet: 'ferox'}]},
      ])
      history.status.should == 'synonym'
      history.epithet.should == 'ferox'
    end
    it "should overrule synonymy with revival from synonymy" do
      @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {revived_from_synonymy: true},
      ]).status.should == 'valid'
    end
    it "should overrule synonymy with raisal to species with revival from synonymy" do
      @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {raised_to_species: {revived_from_synonymy:true}},
      ]).status.should == 'valid'
    end
    it "should stop on 'first available replacement' and make it valid" do
      @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {text: [], matched_text: 'hence first available replacement name for'},
        {homonym_of: {primary_or_secondary: :primary, genus_name: 'Formice'}},
      ]).status.should == 'valid'
    end
    it "should stop on 'Replacement name for' and make it valid" do
      @klass.new([
        {text: [], matched_text: ' Replacement name for <i>Acromyrmex gallardoi</i> Santschi, 1936d: 411.'},
        {text: [], matched_text: '[Junior secondary homonym of <i>Sericomyrmex gallardoi</i> Santschi, 1920d: 379.]'},
      ]).status.should == 'valid'
    end
    it "should overrule synonymy with raisal to species with revival from synonymy" do
      @klass.new([
        {synonym_ofs: [{species_epithet: 'ferox'}]},
        {raised_to_species: {revived_from_synonymy:true}},
      ]).status.should == 'valid'
    end
  end

  it "should handle an unavailable name" do
    @klass.new([{unavailable_name: true}]).status.should == 'unavailable'
  end

  it "should handle a nomen nudum" do
    @klass.new([{nomen_nudum: true}]).status.should == 'nomen nudum'
  end

  it "should consider anything with a subspecies list to be valid" do
    @klass.new([
      {synonym_ofs: [{species_epithet: 'ferox'}]},
      {subspecies: [{species_group_epithet: 'falcifer'}]},
    ]).status.should == 'valid'
  end

  describe "Unidentifiable taxa" do
    it "should handle explicit parse" do
      @klass.new([{unidentifiable: true}]).status.should == 'unidentifiable'
    end
    it "should handle 'unidentifiable' in the text" do
      @klass.new([{text: [], matched_text: 'Unidentifiable taxon'},]).status.should == 'unidentifiable'
    end
  end

  it "should handle 'homonym' in the text" do
    @klass.new([{text: [], matched_text: '[Junior secondary homonym of <i>Cerapachys cooperi</i> Arnold, 1915: 14.]'}]).status.should == 'homonym'
  end

  it "should handle an unresolved homonym even if it's a current subspecies" do
    @klass.new([
      {homonym_of: {:unresolved=>true}},
      {currently_subspecies_of: {}},
    ]).status.should == 'unresolved homonym'
  end

  it "should a taxon excluded from Formicidae" do
    @klass.new([{text: [], matched_text: 'Excluded from Formicidae'}]).status.should == 'excluded'
  end

  it "should handle it when information is in matched_text" do
    @klass.new([{text: [], matched_text: ' Unidentifiable taxon, <i>incertae sedis</i> in <i>Acromyrmex</i>: Kempf, 1972a: 16.'}]).status.should == 'unidentifiable'
  end

  it "should handle unnecessary replacement name in text" do
    history = @klass.new([{text: [], matched_text: ' Unnecessary replacement name for <i>Odontomachus tyrannicus</i> Smith, F. 1861b: 44 and hence junior synonym of <i>gladiator</i> Mayr, 1862: 712, the first available replacement name: Brown, 1978c: 556.'}])
    history.status.should == 'synonym'
    history.epithet.should == 'gladiator'
  end

  it "should handle both a first and second replacement name" do
    history = @klass.new([
      {homonym_of:
        {primary_or_secondary: :primary, species_epithet:'jacobsoni'},
       matched_text: " [Junior primary homonym of <i>jacobsoni</i> Forel, above.]"},
      {text: [], matched_text: " First replacement name: <i>menozzii</i> Donisthorpe, 1941k: 237. "},
      {text: [], matched_text: "Second (unnecessary) replacement name: <i>ineditus</i> Baroni Urbani, 1971b: 360."},
        ])
    history.status.should == 'homonym'
    history.epithet.should == 'menozzii'
  end
end
