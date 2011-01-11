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
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acanthognathus', :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :available => true, :valid => true, :fossil => false}}
  end

  it 'should parse a normal genus name' do
    line = %{<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>   
      {:name => 'Acanthognathus', :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :available => true, :valid => true, :fossil => false}}
  end

  it 'should parse a fossil genus name' do
    line = %{*<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acanthognathus', :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :available => true, :valid => true, :fossil => true}}
  end

  it 'should parse an unidentifiable genus name' do
    line = %{*<b><i><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]</p>}
    Bolton::GenusCatalogParser.parse(line).should == :unidentifiable
  end

  it 'should parse the subfamily and tribe' do
    line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acromyrmex', :subfamily => 'Myrmicinae', :tribe => 'Attini', :available => true, :valid => true, :fossil => false}}
  end

  it "should recognize a subgenus" do
    line = %{#<b><i><span style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i>Lasius</i>]}
    Bolton::GenusCatalogParser.parse(line).should == :subgenus
  end

  it "should recognize an invalid name" do
    line = %{<i><span style='color:black'>ACALAMA</span></i> [junior synonym of <i>Gauromyrmex</i>]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acalama', :available => true, :valid => false, :fossil => false}}
  end

  it "should recognize an invalid name that has no color (like Claude)" do
    line = %{<i>ACIDOMYRMEX</i> [junior synonym of <i>Rhoptromyrmex</i>]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Acidomyrmex', :available => true, :valid => false, :fossil => false}}
  end

  it "should recognize an unavailable name" do
    line = %{<i><span style='color:purple'>ANCYLOGNATHUS</span></i> [<i>Nomen nudum</i>]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Ancylognathus', :available => false, :valid => false, :fossil => false}}
  end

  it "should handle an uncertain tribe" do
    line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Protazteca', :subfamily => 'Dolichoderinae', :tribe => 'incertae sedis', :available => true, :valid => true, :fossil => false}}
  end

  it "should handle an extinct subfamily" do
    line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Myrmicinae]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Protazteca', :subfamily => 'Myrmicinae', :available => true, :valid => true, :fossil => false}}
  end

  it "should handle an extinct subfamily and extinct tribe" do
    line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Specomyrminae: *Sphecomyrmini]}
    Bolton::GenusCatalogParser.parse(line).should == {:genus =>
      {:name => 'Protazteca', :subfamily => 'Specomyrminae', :tribe => 'Sphecomyrmini', :available => true, :valid => true, :fossil => false}}
  end

end
