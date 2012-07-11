require 'spec_helper'

describe EpithetSearchSet do

  describe "Masculine-feminine-neuter" do
    describe "First declension" do
      it "should convert between these" do
        EpithetSearchSet.new('subterranea').epithets.should =~ ['subterraneus', 'subterranea', 'subterraneum']
        EpithetSearchSet.new('subterraneus').epithets.should =~ ['subterranea', 'subterraneus', 'subterraneum']
        EpithetSearchSet.new('subterraneum').epithets.should =~ ['subterraneum', 'subterraneus', 'subterranea']
        EpithetSearchSet.new('equus').epithets.should =~ ['equus', 'equa', 'equum']
        EpithetSearchSet.new('anea').epithets.should =~ ['aneus', 'anea', 'aneum']
        EpithetSearchSet.new('fuscovarius').epithets.should =~ ['fuscovarius', 'fuscovaria', 'fuscovarium']
        EpithetSearchSet.new('euguniae').epithets.should =~ ['euguniae', 'eugunii', 'euguni']
        EpithetSearchSet.new('eugunii').epithets.should =~ ['eugunii', 'euguniae', 'euguni']
    describe "First and second declension adjectives in -er" do
      it "should at least handle coniger" do
        EpithetSearchSet.new('coniger').epithets.should == ['coniger', 'conigera', 'conigerum', 'conigaer', 'conigaera', 'conigaerum']
        EpithetSearchSet.new('conigera').epithets.should == ['conigera', 'conigerus', 'conigerum', 'coniger', 'conigaera', 'conigaerus', 'conigaerum', 'conigaer']
        EpithetSearchSet.new('conigerum').epithets.should == ['conigerum', 'conigerus', 'conigera', 'coniger', 'conigaerum', 'conigaerus', 'conigaera', 'conigaer']
      end
    end
    describe "Third declension" do
      it "should convert between these" do
        EpithetSearchSet.new('fatruele').epithets.should =~ ['fatruele', 'fatruelis']
        EpithetSearchSet.new('fatruelis').epithets.should =~ ['fatruelis', 'fatruele']
      end
    end
  end

  describe "Names deemed identical" do
    it "should handle -i and -ii" do
      EpithetSearchSet.new('lundii').epithets.should == ['lundii', 'lundiae', 'lundi']
      EpithetSearchSet.new('lundi').epithets.should == ['lundi', 'lundae', 'lundii']
      EpithetSearchSet.new('lundae').epithets.should == ['lundae', 'lundi', 'lundii']
    end
    it "should handle -e- and -ae-" do
      EpithetSearchSet.new('levis').epithets.should == ['levis', 'leve', 'laevis', 'laeve']
      EpithetSearchSet.new('laevis').epithets.should == ['laevis', 'laeve', 'levis', 'leve']
    end
    it "should handle -p- and -ph-" do
      EpithetSearchSet.new('delpina').epithets.should =~ ['delpinus', 'delphinus', 'delpina', 'delphina', 'delpinum', 'delphinum']
    end
    it "should handle -v- and -w-" do
      EpithetSearchSet.new('acwabimans').epithets.should =~ ['acwabimans', 'acvabimans']
    end
  end

  describe "Names frequently misspelled" do
    it "should translate them, but just one time and in only one direction" do
      EpithetSearchSet.new('alfaroi').epithets.should == ['alfaroi', 'alfari', 'alfarae', 'alfarii']
      EpithetSearchSet.new('alfari').epithets.should == ['alfari', 'alfarae', 'alfarii']
      EpithetSearchSet.new('columbica').epithets.should == ['columbica', 'colombica', 'columbicus', 'columbicum', 'colombicus', 'colombicum']
    end
  end

end
