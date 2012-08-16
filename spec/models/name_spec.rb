require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  it "should not allow duplicates" do
    Name.create! name: 'Atta'
    Name.new(name: 'Atta').should_not be_valid
  end

  it "should format the fossil symbol" do
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>major</i>'
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(false).should == '<i>major</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>Atta</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(false).should == '<i>Atta</i>'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(true).should == '&dagger;Attanae'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(false).should == 'Attanae'

    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(false).should == '<i>Atta major</i>'
    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(true).should == '<i>&dagger;</i><i>Atta major</i>'
  end

end
