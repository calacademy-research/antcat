require 'spec_helper'

describe Genus do

  it "should have a tribe" do
    attini = Tribe.create! :name => 'Attini', :subfamily => Subfamily.create!(:name => 'Myrmicinae', :status => 'valid'), :status => 'valid'
    Genus.create! :name => 'Atta', :tribe => attini, :status => 'valid'
    Genus.find_by_name('Atta').tribe.should == attini
  end

  it "should have species, which are its children" do
    atta = Genus.create! :name => 'Atta', :status => 'valid'
    Species.create! :name => 'robusta', :genus => atta, :status => 'valid'
    Species.create! :name => 'saltensis', :genus => atta, :status => 'valid'
    atta = Genus.find_by_name('Atta')
    atta.species.map(&:name).should =~ ['robusta', 'saltensis']
    atta.children.should == atta.species
  end

  describe "import" do

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
      lambda {Genus.import :name => 'Acalama', :status => :homonym, :homonym_of => ''}.should raise_error
    end

    it "should create each element in chain, if necessary" do
      Genus.import :name => 'Acalama', :status => :valid, :tribe => 'Attini', :subfamily => 'Forminidaie'
      Taxon.count.should == 3
    end

    it "should not recreate each element in chain, if not necessary" do
      Subfamily.create! :name => 'Forminidaie', :status => 'valid'
      Tribe.create! :name => 'Attini', :status => 'valid'
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

    it "should set the homonym_of correctly" do
      Genus.import :name => 'Acamatus', :status => :homonym, :homonym_of => 'Neivamyrmex'
      Taxon.count.should == 2
      acamatus = Genus.find_by_name 'Acamatus'
      neivamyrmex = Genus.find_by_name 'Neivamyrmex'
      acamatus.homonym_of.should == neivamyrmex
      neivamyrmex.homonym_of.should be_nil
    end
  end

end
