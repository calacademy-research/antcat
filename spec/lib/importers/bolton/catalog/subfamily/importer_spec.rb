# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do
    def make_contents content
      %{<html><body><div class=Section1>#{content}</div></body></html>}
    end

    it "should parse the family, then the supersubfamilies" do
      @importer.should_receive(:parse_family).ordered
      @importer.should_receive(:parse_supersubfamilies).ordered
      @importer.import_html make_contents %{
  <p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
      }
    end

    it "should parse a supersubfamily" do
      @importer.should_receive(:parse_family).ordered
      @importer.should_receive(:parse_genera_lists).ordered
      @importer.should_receive(:parse_subfamily).twice.ordered.and_return false
      @importer.should_receive(:parse_genera_lists).ordered

      @importer.import_html make_contents %{
<p><b>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>
<p>THE FORMICOMORPHS: SUBFAMILY FORMICINAE</p>
      }
    end

  end

  describe "Fixing up synonyms" do
    it "should fix up a genus to point to the senior synonym" do
      senior_synonym = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Leptomyrmecini')
      junior_synonym = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Iridomyrmecina'), status: 'synonym', synonym_of: senior_synonym
      synonym_of_junior_synonym = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Anatellina'), status: 'synonym', synonym_of: junior_synonym
      genus_of_synonym_of_junior_synonym = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Iridomyrmex'), tribe: synonym_of_junior_synonym

      @importer.resolve_parent_synonyms

      genus_of_synonym_of_junior_synonym.reload.tribe.name.to_s.should == 'Leptomyrmecini'
    end
    it "should fixup the species of a subgenus to point to the senior synonym" do
      genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Camponotus')
      senior_synonym = FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'Mayria'), genus: genus
      junior_synonym = FactoryGirl.create :subgenus, name: FactoryGirl.create(:name, name: 'Myrmosega'), status: 'synonym', synonym_of: senior_synonym
      species_of_junior_synonym = FactoryGirl.create :species, subgenus: junior_synonym, genus: genus

      @importer.resolve_parent_synonyms

      species_of_junior_synonym.reload.subgenus.name.to_s.should == 'Mayria'
    end
  end

end
