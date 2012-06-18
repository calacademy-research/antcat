require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  describe "Making an epithet search set" do

    it "should put the request term first" do
      Name.make_epithet_set('magus').should == ['magus', 'maga']
      Name.make_epithet_set('maga').should == ['maga', 'magus']
    end

    def epithet_set_for_one_should_include_other *epithets
      epithets.each do |search_epithet|
        epithets.each do |target_epithet|
          if search_epithet != target_epithet
            Name.make_epithet_set(search_epithet).find(target_epithet).should_not be_nil
          end
        end
      end
    end

    describe "Masculine-feminine" do
      it "should convert between these" do
        epithet_set_for_one_should_include_other 'subterranea', 'subterraneus'
        epithet_set_for_one_should_include_other 'magus', 'maga'
        epithet_set_for_one_should_include_other 'diabolicus', 'diabolica'
        epithet_set_for_one_should_include_other 'equus', 'equa'
        epithet_set_for_one_should_include_other 'aneus', 'anea'
        epithet_set_for_one_should_include_other 'eugeniae', 'eugenii'
      end
    end

    it "should convert names deemed identical" do
      epithet_set_for_one_should_include_other 'lundi', 'lundii'
    end

  end

end
