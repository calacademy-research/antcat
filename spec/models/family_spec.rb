# coding: UTF-8
require 'spec_helper'

describe Family do

  describe "Importing" do
    it "should import the family, its protonym and the taxonomic history" do
      reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Latreille')], :citation_year => '1809'
      Reference.should_receive(:find_by_bolton_author_year).and_return reference
      authorship = {:author_names=>["Latreille"], :year=>"1809", :pages=>"124"}
      headline = {:type=>:family_group_headline, :family_or_subfamily_name=>"Formicariae", :authorship=>[{:author_names=>["Latreille"], :year=>"1809", :pages=>"124"}],
 :type_genus=>{:genus_name=>"Formica"}}
      family = Family.import headline, :bar

      family.protonym.name.should == 'Formicariae'

      family.protonym.authorship.pages.should == '124'
      family.protonym.authorship.reference.citation_year.should == '1809'
      family.protonym.authorship.reference.author_names.first.name.should == 'Latreille'
    end
  end

  describe "Statistics" do
    it "should return the statistics for each status of each rank" do
      family = Factory :family
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily, :tribe => nil
      Factory :genus, :subfamily => subfamily, :status => 'homonym', :tribe => nil
      2.times {Factory :subfamily, :fossil => true}
      family.statistics.should == {
        :extant => {:subfamilies => {'valid' => 1}, :genera => {'valid' => 1, 'homonym' => 1}},
        :fossil => {:subfamilies => {'valid' => 2}}
      }
    end
  end

  #it "should have tribes, which are its children" do
    #family = Factory :family, :name => 'Myrmicinae'
    #Factory :tribe, :name => 'Attini', :family => family
    #Factory :tribe, :name => 'Dacetini', :family => family
    #family.tribes.map(&:name).should =~ ['Attini', 'Dacetini']
    #family.tribes.should == family.children
  #end

  #it "should have genera" do
    #myrmicinae = Factory :family, :name => 'Myrmicinae'
    #dacetini = Factory :tribe, :name => 'Dacetini', :family => myrmicinae
    #Factory :genus, :name => 'Atta', :family => myrmicinae, :tribe => Factory(:tribe, :name => 'Attini', :family => myrmicinae)
    #Factory :genus, :name => 'Acanthognathus', :family => myrmicinae, :tribe => Factory(:tribe, :name => 'Dacetini', :family => myrmicinae)
    #myrmicinae.genera.map(&:name).should =~ ['Atta', 'Acanthognathus']
  #end

  #it "should have species" do
    #family = Factory :family
    #genus = Factory :genus, :family => family
    #species = Factory :species, :genus => genus
    #family.should have(1).species
  #end

  #it "should have subspecies" do
    #family = Factory :family
    #genus = Factory :genus, :family => family
    #species = Factory :species, :genus => genus
    #subspecies = Factory :subspecies, :species => species
    #family.should have(1).subspecies
  #end

  #describe "Full name" do
    #it "is just the name" do
      #taxon = Factory :family, :name => 'Dolichoderinae'
      #taxon.full_name.should == 'Dolichoderinae'
    #end
  #end

  #describe "Full label" do
    #it "is just the name" do
      #taxon = Factory :family, :name => 'Dolichoderinae'
      #taxon.full_label.should == 'Dolichoderinae'
    #end
  #end

  #describe "Statistics" do

    #it "should handle 0 children" do
      #family = Factory :family
      #family.statistics.should == {}
    #end

    #it "should handle 1 valid genus" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #family.statistics.should == {:extant => {:genera => {'valid' => 1}}}
    #end

    #it "should handle 1 valid genus and 2 synonyms" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #2.times {Factory :genus, :family => family, :status => 'synonym'}
      #family.statistics.should == {:extant => {:genera => {'valid' => 1, 'synonym' => 2}}} 
    #end

    #it "should handle 1 valid genus with 2 valid species" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #2.times {Factory :species, :genus => genus, :family => family}
      #family.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}}
    #end

    #it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #Factory :species, :genus => genus
      #Factory :subspecies, :species => Factory(:species, :genus => genus)
      #family.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}, :subspecies => {'valid' => 1}}}
    #end

    #it "should differentiate between extinct genera, species and subspecies" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #Factory :genus, :family => family, :fossil => true
      #Factory :species, :genus => genus
      #Factory :species, :genus => genus, :fossil => true
      #Factory :subspecies, :species => Factory(:species, :genus => genus)
      #Factory :subspecies, :species => Factory(:species, :genus => genus), :fossil => true
      #family.statistics.should == {
        #:extant => {:genera => {'valid' => 1}, :species => {'valid' => 3}, :subspecies => {'valid' => 1}},
        #:fossil => {:genera => {'valid' => 1}, :species => {'valid' => 1}, :subspecies => {'valid' => 1}},
      #}
    #end

    #it "should differentiate between extinct genera, species and subspecies" do
      #family = Factory :family
      #genus = Factory :genus, :family => family
      #Factory :genus, :family => family, :fossil => true
      #Factory :species, :genus => genus
      #Factory :species, :genus => genus, :fossil => true
      #Factory :subspecies, :species => Factory(:species, :genus => genus)
      #Factory :subspecies, :species => Factory(:species, :genus => genus), :fossil => true
      #family.statistics.should == {
        #:extant => {:genera => {'valid' => 1}, :species => {'valid' => 3}, :subspecies => {'valid' => 1}},
        #:fossil => {:genera => {'valid' => 1}, :species => {'valid' => 1}, :subspecies => {'valid' => 1}},
      #}
    #end

  #end
end
