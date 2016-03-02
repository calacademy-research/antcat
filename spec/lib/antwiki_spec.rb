#require 'spec_helper'

#describe Antwiki do

  #describe "comparing its valid taxa to ours" do
    #it "should report a missing taxon" do
      #genus = create_genus 'Atta'
      #antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Atta'
      #another_antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Eciton'
      #Antwiki.compare_valid
      #AntwikiValidTaxon.find_by_name('Eciton').result.should == 'missing'
      #AntwikiValidTaxon.find_by_name('Atta').result.should be_nil
      #AntwikiValidTaxon.where("result = 'missing'").count.should == 1
      #AntwikiValidTaxon.where("result IS NULL").count.should == 1
    #end
    #it "should report a taxon that's found, but is invalid" do
      #genus = create_genus 'Atta', status: 'synonym'
      #antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Atta'
      #results = Antwiki.compare_valid
      #AntwikiValidTaxon.find_by_name('Atta').result.should == 'synonym'
      #AntwikiValidTaxon.where("result = 'synonym'").count.should == 1
    #end
    #it "should report a taxon that's not found, but probably because it's new" do
      #old_antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Atta', year: '1900'
      #new_antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Eciton', year: '2013'
      #results = Antwiki.compare_valid
      #AntwikiValidTaxon.find_by_name('Atta').result.should == 'missing'
      #AntwikiValidTaxon.find_by_name('Eciton').result.should == 'new'
    #end
  #end

#end
