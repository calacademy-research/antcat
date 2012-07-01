require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  describe "Making an epithet search set" do

    describe "Masculine-feminine-neuter" do
      describe "First declension" do
        it "should convert between these" do
          Name.make_epithet_set('subterranea').should =~ ['subterraneus', 'subterranea', 'subterraneum']
          Name.make_epithet_set('subterraneus').should =~ ['subterranea', 'subterraneus', 'subterraneum']
          Name.make_epithet_set('subterraneum').should =~ ['subterraneum', 'subterraneus', 'subterranea']
          Name.make_epithet_set('equus').should =~ ['equus', 'equa', 'equum']
          Name.make_epithet_set('anea').should =~ ['aneus', 'anea', 'aneum']
          Name.make_epithet_set('fuscovarius').should =~ ['fuscovarius', 'fuscovaria', 'fuscovarium']
          Name.make_epithet_set('euguniae').should =~ ['euguniae', 'eugunii']
          Name.make_epithet_set('eugunii').should =~ ['eugunii', 'euguniae', 'euguni']
        end
      end
      describe "Third declension" do
        it "should convert between these" do
          Name.make_epithet_set('fatruele').should =~ ['fatruele', 'fatruelis']
          Name.make_epithet_set('fatruelis').should =~ ['fatruelis', 'fatruele']
        end
      end
    end

    describe "Names deemed identical" do
      it "should handle -i and -ii" do
        Name.make_epithet_set('lundii').should == ['lundii', 'lundiae', 'lundi']
        Name.make_epithet_set('lundi').should == ['lundi', 'lundae', 'lundii']
        Name.make_epithet_set('lundae').should == ['lundae', 'lundi']
      end
      it "should handle -e- and -ae-" do
        Name.make_epithet_set('levis').should == ['levis', 'leve', 'laevis', 'laeve']
        Name.make_epithet_set('laevis').should == ['laevis', 'laeve', 'levis', 'leve']
      end
      it "should handle -p- and -ph-" do
        Name.make_epithet_set('delpina').should =~ ['delpinus', 'delphinus', 'delpina', 'delphina', 'delpinum', 'delphinum']
      end
    end

    describe "Names frequently misspelled" do
      it "should translate them, but just one time" do
        Name.make_epithet_set('alfaroi').should == ['alfaroi', 'alfari']
      end
    end

  end

end
