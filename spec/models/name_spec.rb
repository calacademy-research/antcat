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
    SpeciesName.new(html_epithet: '<i>major</i>').html_epithet_with_fossil(true).should == '<i>&dagger;</i><i>major</i>'
    SpeciesName.new(html_epithet: '<i>major</i>').html_epithet_with_fossil(false).should == '<i>major</i>'
    GenusName.new(html_epithet: '<i>Atta</i>').html_epithet_with_fossil(true).should == '<i>&dagger;</i><i>Atta</i>'
    GenusName.new(html_epithet: '<i>Atta</i>').html_epithet_with_fossil(false).should == '<i>Atta</i>'
    SubfamilyName.new(html_epithet: 'Attanae').html_epithet_with_fossil(true).should == '&dagger;Attanae'
    SubfamilyName.new(html_epithet: 'Attanae').html_epithet_with_fossil(false).should == 'Attanae'

    SpeciesName.new(html_name: '<i>Atta major</i>').to_html_with_fossil(false).should == '<i>Atta major</i>'
    SpeciesName.new(html_name: '<i>Atta major</i>').to_html_with_fossil(true).should == '<i>&dagger;</i><i>Atta major</i>'
  end

end
