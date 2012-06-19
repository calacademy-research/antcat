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
          Name.make_epithet_set('eugeniae').should =~ ['eugeniae', 'eugenii']
          Name.make_epithet_set('eugeniae').should =~ ['eugeniae', 'eugenii']
        end
      end
      describe "Third declension" do
        it "should convert between these" do
          Name.make_epithet_set('patruele').should =~ ['patruele', 'patruelis']
          Name.make_epithet_set('patruelis').should =~ ['patruelis', 'patruele']
        end
      end
    end

    it "should convert names deemed identical" do
      Name.make_epithet_set('lundii').should == ['lundii', 'lundiae', 'lundi']
      Name.make_epithet_set('lundi').should == ['lundi', 'lundae', 'lundii']
      Name.make_epithet_set('lundae').should == ['lundae', 'lundi']
    end

  end

end
