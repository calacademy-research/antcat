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

  it "should have subgenera" do
    atta = Factory :genus, :name => 'Atta'
    Factory :subgenus, :name => 'robusta', :genus => atta
    Factory :subgenus, :name => 'saltensis', :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.subgenera.map(&:name).should =~ ['robusta', 'saltensis']
  end

  describe "import" do

    it "should import all the fields correctly" do
      genus = Genus.import :name => 'Atta',
        :fossil => true, :status => 'valid',
        :taxonomic_history => '<p>history</p>',
        :incertae_sedis_in => 'family'
      genus.reload
      genus.name.should == 'Atta'
      genus.fossil?.should be_true
      genus.status.should == 'valid'
      genus.taxonomic_history.should == '<p>history</p>'
      genus.incertae_sedis_in.should == 'family'
    end

    it "should leave incertae_sedis_in nil" do
      genus = Genus.import :name => 'Atta', :status => 'valid'
      genus.incertae_sedis_in.should be_nil
    end

    it "should not consider Pseudoatta extinct, no matter what Bolton said in one document at one time" do
      genus = Genus.import :name => 'Pseudoatta', :status => 'valid', :fossil => true
      genus.reload.should_not be_fossil
    end

    it "should not consider these as subfamilies" do
      ['Aculeata', 'Symphyta', 'Apocrita', 'Homoptera', 'Ichneumonidae', 'Embolemidae'].each do |name|
        genus = Genus.import :name => 'Cariridris', :subfamily => name
        genus.reload.subfamily.should be_nil
      end
    end

    it "should not create the genus if the passed-in subfamily isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => 'valid', :subfamily => ''}.should raise_error
    end
    it "should not create the genus if the passed-in tribe isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => 'valid', :tribe => ''}.should raise_error
    end
    it "should not create the genus if the passed-in synonym_of isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => :synonym, :synonym_of => ''}.should raise_error
    end
    it "should not create the genus if the passed-in homonym_of isn't valid" do
      lambda {Genus.import :name => 'Acalama', :status => 'homonym', :homonym_resolved_to => ''}.should raise_error
    end

    it "should create each element in chain, if necessary" do
      Genus.import :name => 'Acalama', :status => 'valid', :tribe => 'Attini', :subfamily => 'Forminidaie'
      Taxon.count.should == 3
    end

    it "should not recreate each element in chain, if not necessary" do
      Factory :subfamily, :name => 'Forminidaie'
      Factory :tribe, :name => 'Attini'
      Genus.import :name => 'Acalama', :status => 'valid', :tribe => 'Attini', :subfamily => 'Forminidaie'
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
      Genus.import :name => 'Acamatus', :status => 'homonym', :homonym_resolved_to => 'Neivamyrmex'
      Taxon.count.should == 2
      acamatus = Genus.find_by_name 'Acamatus'
      neivamyrmex = Genus.find_by_name 'Neivamyrmex'
      acamatus.homonym_resolved_to.should == neivamyrmex
      neivamyrmex.homonym_resolved_to.should be_nil
    end

    it "should respect homonyms" do
      Genus.import :name => 'Acrostigma', :status => 'homonym', :homonym_resolved_to => 'Stigmacros'
      Genus.import :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma'
      Genus.count.should == 4
    end

    it "should leave the status nil when the target of homonym/synonym, then set it properly after being imported directly" do
      Genus.import :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma'
      Genus.import :name => 'Acalama', :status => 'homonym', :homonym_resolved_to => 'Stigmacros'
      Genus.import :name => 'Atta', :status => 'valid', :tribe => 'Attini', :subfamily => 'Myrmicinae'
      Taxon.count.should == 7
      Genus.find_by_name('Podomyrma').status.should be_nil
      Genus.find_by_name('Stigmacros').status.should be_nil
      Subfamily.find_by_name('Myrmicinae').status.should == 'valid'
      Tribe.find_by_name('Attini').status.should == 'valid'

      Genus.import :name => 'Stigmacros', :status => 'valid', :homonym_resolved_to => 'Stigmacros'
      Genus.find_by_name('Stigmacros').status.should == 'valid'
    end

  end

  describe "A genus synonymized to a subgenus" do

    it "should look for both genera and subgenera when looking for its synonym" do
      Genus.import :name => 'Shuckardia', :status => :synonym, :synonym_of => 'Alaopone'
      Subgenus.import :name => 'Alaopone', :status => 'valid', :genus => 'Dorylus'
      Taxon.count.should == 3
    end

    it "should look for both genera and subgenera when looking for its synonym" do
      Subgenus.import :name => 'Alaopone', :status => 'valid', :genus => 'Dorylus'
      Genus.import :name => 'Shuckardia', :status => :synonym, :synonym_of => 'Alaopone'
      Taxon.count.should == 3
    end

  end

  describe "A genus homonymized to a subgenus" do

    it "should look for both genera and subgenera when looking for its homonym" do
      orthonotus = Genus.import :name => 'Orthonotus', :status => 'homonym', :homonym_resolved_to => 'Orthonotomyrmex'
      orthonotomyrmex = Subgenus.import :name => 'Orthonotomyrmex', :status => 'valid', :genus => 'Dorylus'
      Taxon.count.should == 3
      orthonotus.reload.homonym_resolved_to.should == orthonotomyrmex
    end

    it "should look for both genera and subgenera when looking for its homonym" do
      orthonotomyrmex = Subgenus.import :name => 'Orthonotomyrmex', :status => 'valid', :genus => 'Dorylus'
      orthonotus = Genus.import :name => 'Orthonotus', :status => 'homonym', :homonym_resolved_to => 'Orthonotomyrmex'
      Taxon.count.should == 3
      orthonotus.reload.homonym_resolved_to.should == orthonotomyrmex
    end

  end

  describe "Reimporting, when information changes" do
    describe "Setting the subfamily" do

      it "should allow setting a subfamily if none existed before" do
        Factory :genus, :name => 'Camponotites'
        lambda {Genus.import :name => 'Camponotites', :subfamily => 'Formicinae', :status => 'valid'}.should_not raise_error
      end

      it "should not allow setting a subfamily if one did exist before and they're not the same" do
        Factory :genus, :name => 'Camponotites', :subfamily => Factory(:subfamily, :name => 'Formicinae')
        lambda {Genus.import :name => 'Camponotites', :subfamily => 'Dolichoderinae', :status => 'valid'}.should raise_error
      end

      it "should allow setting a subfamily if one did exist before and they are the same" do
        Factory :genus, :name => 'Camponotites', :subfamily => Factory(:subfamily, :name => 'Formicinae')
        lambda {Genus.import :name => 'Camponotites', :subfamily => 'Formicinae', :status => 'valid'}.should_not raise_error
      end

    end

    describe "Setting the tribe" do

      it "should allow setting a tribe if none existed before" do
        Factory :genus, :name => 'Camponotites'
        lambda {Genus.import :name => 'Camponotites', :tribe => 'Camponotini', :status => 'valid'}.should_not raise_error
      end

      it "should not allow setting a tribe if one did exist before and they're not the same" do
        Factory :genus, :name => 'Camponotites', :tribe => Factory(:tribe, :name => 'Camponotini')
        lambda {Genus.import :name => 'Camponotites', :tribe => 'Aneuretini', :status => 'valid'}.should raise_error
      end

      it "should allow setting a tribe if one did exist before and they are the same" do
        Factory :genus, :name => 'Camponotites', :tribe => Factory(:tribe, :name => 'Camponotini')
        lambda {Genus.import :name => 'Camponotites', :tribe => 'Camponotini', :status => 'valid'}.should_not raise_error
      end

    end

    describe "Setting the fossil flag" do

      it "should not allow changing the fossil flag" do
        Factory :genus, :name => 'Camponotites'
        lambda {Genus.import :name => 'Camponotites', :status => 'valid', :fossil => true}.should raise_error
      end

      it "should allow setting the fossil flag to the same thing" do
        Factory :genus, :name => 'Camponotites', :fossil => true
        lambda {Genus.import :name => 'Camponotites', :status => 'valid', :fossil => true}.should_not raise_error
      end

    end
  end
end
