# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupTaxon do

  it "can have a subfamily" do
    genus = create_genus 'Afropone'
    FactoryGirl.create :species_group_taxon, name: FactoryGirl.create(:name, name: 'championi'), genus: genus
    SpeciesGroupTaxon.find_by_name('championi').subfamily.should == genus.subfamily
  end

  it "doesn't have to have a subfamily" do
    FactoryGirl.create(:species_group_taxon, subfamily: nil).should be_valid
  end

  it "must have a genus" do
    taxon = FactoryGirl.build :species_group_taxon, genus: nil
    taxon.should_not be_valid
    genus = create_genus
    taxon.update_attributes genus: genus
    taxon = SpeciesGroupTaxon.find taxon
    taxon.should be_valid
    taxon.genus.should == genus
  end

  it "can have a subgenus" do
    subgenus = create_subgenus
    taxon = FactoryGirl.create :species_group_taxon, subgenus: subgenus
    SpeciesGroupTaxon.find(taxon).subgenus.should == subgenus
  end

  it "doesn't have to have a subgenus" do
    FactoryGirl.build(:species_group_taxon, subgenus: nil).should be_valid
  end

  it "has its subfamily set from its genus" do
    genus = create_genus
    genus.subfamily.should_not be_nil
    taxon = FactoryGirl.create :species_group_taxon, genus: genus, subfamily: nil
    taxon.subfamily.should == genus.subfamily
  end

  describe "Importing" do
    it "should raise an error if there is no protonym" do
      genus = create_genus 'Afropone'
      -> {
        SpeciesGroupTaxon.import(genus: genus, species_group_epithet: 'orapa', unparseable: 'asdfasdf')
      }.should raise_error Species::NoProtonymError
    end
  end

  #describe "Setting status from history" do
    #it "should handle no history" do
      #species = FactoryGirl.create :species
      #for history in [nil, []]
        #species.set_status_from_history history
        #Species.find(species).reload.status.should == 'valid'
      #end
    #end
    #it "should recognize a synonym_of" do
      #genus = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta')
      #ferox = FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'Atta ferox'), genus: genus
      #species = FactoryGirl.create :species, genus: genus
      #history = [{synonym_ofs: [{species_epithet: 'ferox', junior_or_senior: :junior}]}]
      #species.set_status_from_history history
      #species = Species.find species
      #ForwardReference.fixup
      ##species.should be_synonym
      ##species.synonym_of?(ferox).should be_true
    #end
    #it "should find the senior synonym using declension rules" do
      #genus = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta')
      #magna = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta magna', epithet: 'magna'), genus: genus
      #species = FactoryGirl.create :species, genus: genus
      #history = [{synonym_ofs: [{species_epithet: 'magnus', junior_or_senior: :junior}]}]
      #species.set_status_from_history history
      #species = Species.find species
      ##species.should be_synonym
      ##species.synonym_of?(ferox).should be_true
    #end
    #it "should recognize a synonym_of even if it's not the first item in the history" do
      #genus = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta')
      #ferox = FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'Atta texanus'), genus: genus
      #species = FactoryGirl.create :species, genus: genus
      #history = 
        #[{combinations_in:
          #[{genus_name:"Acanthostichus",
            #subgenus_epithet:"Ctenopyga",
            #references:
              #[{author_names:["Emery"],
                #year:"1911d",
                #pages:"14",
                #matched_text:"Emery, 1911d: 14"}]}],
          #matched_text:
          #" Combination in <i>Acanthostichus (Ctenopyga)</i>: Emery, 1911d: 14."},
        #{:synonym_ofs=>
          #[{:species_epithet=>"texanus",
            #:references=>
              #[{:author_names=>["Smith, M.R."],
                #:year=>"1955a",
                #:pages=>"49",
                #:matched_text=>"Smith, M.R. 1955a: 49"}],
            #:junior_or_senior=>:junior}],
          #:matched_text=>
          #" Junior synonym of <i>texanus</i>: Smith, M.R. 1955a: 49."}]

      #species.set_status_from_history history
      #species.reload.should be_synonym
    #end

  #end

end
