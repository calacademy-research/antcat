require 'spec_helper'

describe Genus do

  it "should have a tribe" do
    attini = Factory :tribe, :name => 'Attini', :subfamily => Factory(:subfamily, :name => 'Myrmicinae')
    Factory :genus, :name => 'Atta', :tribe => attini
    Genus.find_by_name('Atta').tribe.should == attini
  end

  it "should have species, which are its children" do
    atta = Factory :genus, :name => 'Atta'
    Factory :species, :name => 'robusta', :genus => atta
    Factory :species, :name => 'saltensis', :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.species.map(&:name).should =~ ['robusta', 'saltensis']
    atta.children.should == atta.species
  end

  describe "import" do

    it "should import all the fields correctly" do
      genus = Genus.import :name => 'Atta',
        :fossil => true, :status => :valid,
        :taxonomic_history => '<p>history</p>',
        :incertae_sedis_in => :family
      genus.reload
      genus.name.should == 'Atta'
      genus.fossil?.should be_true
      genus.status.should == 'valid'
      genus.taxonomic_history.should == '<p>history</p>'
      genus.incertae_sedis_in.should == 'family'
    end

    it "should leave incertae_sedis_in nil" do
      genus = Genus.import :name => 'Atta', :status => :valid
      genus.incertae_sedis_in.should be_nil
    end

    it "should not create the genus if the passed-in subfamily isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => :valid, :subfamily => ''}.should raise_error
    end
    it "should not create the genus if the passed-in tribe isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => :valid, :tribe => ''}.should raise_error
    end
    it "should not create the genus if the passed-in synonym_of isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => :synonym, :synonym_of => ''}.should raise_error
    end
    it "should not create the genus if the passed-in homonym_of isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => :homonym, :homonym_resolved_to => ''}.should raise_error
    end

    it "should create each element in chain, if necessary" do
      Genus.import :name => 'Acalama', :status => :valid, :tribe => 'Attini', :subfamily => 'Forminidaie'
      Taxon.count.should == 3
    end

    it "should not recreate each element in chain, if not necessary" do
      Factory :subfamily, :name => 'Forminidaie'
      Factory :tribe, :name => 'Attini'
      Genus.import :name => 'Acalama', :status => :valid, :tribe => 'Attini', :subfamily => 'Forminidaie'
      Taxon.count.should == 3
    end

    it "should set the synonym_of correctly" do
      Genus.import :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'
      Taxon.count.should == 2
      acalama = Genus.find_by_name 'Acalama'
      gauromyrmex = Genus.find_by_name 'Gauromyrmex'
      acalama.synonym_of.should == gauromyrmex
      gauromyrmex.synonym_of.should be_nil
    end

    it "should set the homonym_resolved_to correctly" do
      Genus.import :name => 'Acamatus', :status => :homonym, :homonym_resolved_to => 'Neivamyrmex'
      Taxon.count.should == 2
      acamatus = Genus.find_by_name 'Acamatus'
      neivamyrmex = Genus.find_by_name 'Neivamyrmex'
      acamatus.homonym_resolved_to.should == neivamyrmex
      neivamyrmex.homonym_resolved_to.should be_nil
    end

    it "should respect homonyms" do
      Genus.import :name => 'Acrostigma', :status => :homonym, :homonym_resolved_to => 'Stigmacros'
      Genus.import :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma'
      Genus.count.should == 4
    end

    it "should leave the status nil when the target of homonym/synonym, then set it properly after being imported directly" do
      Genus.import :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma'
      Genus.import :name => 'Acalama', :status => :homonym, :homonym_resolved_to => 'Stigmacros'
      Genus.import :name => 'Atta', :status => :valid, :tribe => 'Attini', :subfamily => 'Myrmicinae'
      Taxon.count.should == 7
      Genus.find_by_name('Podomyrma').status.should be_nil
      Genus.find_by_name('Stigmacros').status.should be_nil
      Subfamily.find_by_name('Myrmicinae').status.should == 'valid'
      Tribe.find_by_name('Attini').status.should == 'valid'

      Genus.import :name => 'Stigmacros', :status => :valid, :homonym_resolved_to => 'Stigmacros'
      Genus.find_by_name('Stigmacros').status.should == 'valid'
    end

    it "scream and holler if the same genus with the same status is imported twice" do
      Genus.import :name => 'Acrostigma', :status => :valid
      lambda {Genus.import :name => 'Acrostigma', :status => :valid}.should raise_error
    end
  end

end
