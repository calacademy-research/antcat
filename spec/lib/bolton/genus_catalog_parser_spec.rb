require 'spec_helper'

describe Bolton::GenusCatalogParser do
  it 'should parse a normal genus name' do
    line = %q{
<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]
    }
    Bolton::GenusCatalogParser.parse(line).should == {:genus => {:name => 'Acanthognathus', :fossil => false}}
  end
  it 'should parse a fossil genus name' do
    line = %q{
*<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]
    }
    Bolton::GenusCatalogParser.parse(line).should == {:genus => {:name => 'Acanthognathus', :fossil => true}}
  end
end
