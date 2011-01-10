require 'spec_helper'

describe Bolton::GenusCatalogParser do
  it 'should handle complete garbage' do
    line = %{asdfj;jsdf}
    Bolton::GenusCatalogParser.parse(line).should == :unparseable
  end

  it 'should handle all sorts of guff within the tags' do
    line = %{<b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus => {:name => 'Acanthognathus', :fossil => false, :subfamily => 'Myrmicinae', :tribe => 'Dacetini'}}
  end

  it 'should parse a normal genus name' do
    line = %{<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus => {:name => 'Acanthognathus', :fossil => false, :subfamily => 'Myrmicinae', :tribe => 'Dacetini'}}
  end

  it 'should parse a fossil genus name' do
    line = %{*<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus => {:name => 'Acanthognathus', :fossil => true, :subfamily => 'Myrmicinae', :tribe => 'Dacetini'}}
  end

  it 'should parse an unidentifiable genus name' do
    line = %{*<b><i><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]</p>}
    Bolton::GenusCatalogParser.parse(line).should == :unidentifiable
  end

  it 'should parse the subfamily and tribe' do
    line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acromyrmex', :subfamily => 'Myrmicinae', :tribe => 'Attini', :fossil => false}
    }
  end

end
