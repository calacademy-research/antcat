# coding: UTF-8
require 'spec_helper'

describe Family do

  describe "Importing" do
    it "should create the Family, Protonym, and Citation, and should link to the right Genus and Reference" do
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      data =  {
        :protonym => {
          :name => "Formicariae",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_genus => 'Formica',
        :taxonomic_history => "Formicidae as family"
      }

      family = Family.import(data).reload
      family.taxonomic_history.should == "Formicidae as family"
      family.name.should == 'Formicidae'
      family.should_not be_invalid
      family.should_not be_fossil

      protonym = family.protonym
      protonym.name.should == 'Formicariae'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference
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

  describe "Full label" do
    it "should be the family name" do
      Factory(:family, :name => 'Formicidae').full_label.should == 'Formicidae'
    end
  end

end
