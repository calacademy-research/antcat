# coding: UTF-8
require 'spec_helper'

describe EpithetSearchSet do

  describe "Masculine-feminine-neuter" do
    describe "First declension" do
      it "should convert between these" do
        EpithetSearchSet.new('subterranea').epithets.should == ['subterranea', 'subterraneus', 'subterraneum']
        EpithetSearchSet.new('subterraneus').epithets.should == ['subterraneus', 'subterranea', 'subterraneum']
        EpithetSearchSet.new('subterraneum').epithets.should == ['subterraneum', 'subterraneus', 'subterranea']
        EpithetSearchSet.new('equus').epithets.should == ['equus', 'equa', 'equum']
        EpithetSearchSet.new('anea').epithets.should == ['anea', 'aneus', 'aneum']
        EpithetSearchSet.new('fuscobarius').epithets.should == ['fuscobarius', 'fuscobaria', 'fuscobarium']
        EpithetSearchSet.new('euguniae').epithets.should == ['euguniae', 'eugunii']
        EpithetSearchSet.new('eugunii').epithets.should == ['eugunii', 'euguniae', 'euguni']
      end
    end
    describe "First and second declension adjectives in -er" do
      it "should at least handle coniger" do
        EpithetSearchSet.new('coniger').epithets.should == ['coniger', 'conigera', 'conigerum', 'conigaer']
        EpithetSearchSet.new('conigera').epithets.should == ['conigera', 'conigerus', 'conigerum', 'coniger', 'conigaera']
        EpithetSearchSet.new('conigerum').epithets.should == ['conigerum', 'conigerus', 'conigera', 'coniger', 'conigaerum']
      end
    end
    describe "Third declension" do
      it "should convert between these" do
        EpithetSearchSet.new('fatruele').epithets.should == ['fatruele', 'fatruelis']
        EpithetSearchSet.new('fatruelis').epithets.should == ['fatruelis', 'fatruele']
      end
    end
  end

  describe "Names deemed identical" do
    it "should handle -i and -ii" do
      EpithetSearchSet.new('lundii').epithets.should == ['lundii', 'lundiae', 'lundi']
      EpithetSearchSet.new('lundi').epithets.should == ['lundi', 'lundae', 'lundii']
      EpithetSearchSet.new('lundae').epithets.should == ['lundae', 'lundi']
    end
    it "should handle -e- and -ae-" do
      EpithetSearchSet.new('letis').epithets.should == ['letis', 'lete', 'laetis']
      EpithetSearchSet.new('laetis').epithets.should == ['laetis', 'laete', 'letis']
    end
    it "should handle -p- and -ph-" do
      EpithetSearchSet.new('delpina').epithets.should == ['delpina', 'delpinus', 'delpinum', 'delphina']
    end
    it "should handle -v- and -w-" do
      EpithetSearchSet.new('acwabimans').epithets.should == ['acwabimans', 'acvabimans']
      EpithetSearchSet.new('acvabimans').epithets.should == ['acvabimans', 'acwabimans']
    end
  end

  describe "Names frequently misspelled" do
    it "should translate them, but just one time and in only one direction" do
      EpithetSearchSet.new('alfaroi').epithets.should == ['alfaroi', 'alfari']
      EpithetSearchSet.new('alfari').epithets.should == ['alfari', 'alfarae', 'alfarii']
      EpithetSearchSet.new('columbica').epithets.should == ['columbica', 'colombica', 'columbicus', 'columbicum']
    end
  end

end
