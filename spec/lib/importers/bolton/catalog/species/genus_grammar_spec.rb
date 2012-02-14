# coding: UTF-8
require 'spec_helper'

#describe Importers::Bolton::Catalog::Species::Importer do
  #before do
    #@importer = Importers::Bolton::Catalog::Species::Importer.new
  #end

  #describe "parsing genus see-under heading" do
    #it "should handle when colon is italicized" do
      #@importer.parse("<i>ASKETOGENYS:</i> see under <b><i>PYRAMICA</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize a simple see-under" do
      #@importer.parse("<i>ACANTHOLEPIS</i>: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize a genus with an author" do
      #@importer.parse("<i>ACROSTIGMA</i> Emery: see under <b><i>LEPISIOTA</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize a subgenus" do
      #@importer.parse("<i><span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize an extinct genus" do
      #@importer.parse("*<i>ACROSIYGMA</i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize a subgenus" do
      #@importer.parse("<i><span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize an extinct subgenus" do
      #@importer.parse("*<i><span style='color:blue'>ACANTHOMYOPS</span></i>: see under <b><i>LASIUS</i></b>.").should == {:type => :see_under}
    #end
    #it "should recognize an extinct referent" do
      #@importer.parse("<i>ACANTHOMYOPS</i>: see under *<b><i>LASIUS</i></b>.").should == {:type => :see_under}
    #end
    #it "should not freak if there's no period at the end" do
      #@importer.parse("<i>AROTROPUS</i>: see under <b><i>AMBLYOPONE</i></b>").should == {:type => :see_under}
    #end
    #it "should not freak if there's no colon after the referer" do
      #@importer.parse("<i>ASKETOGENYS</i> see under <b><i>PYRAMICA</i></b>").should == {:type => :see_under}
    #end
    #it "should handle space between the referer and the colon" do
      #@importer.parse("<i>MACROMISCHOIDES</i> : see under <b><i>TETRAMORIUM</i></b>").should == {:type => :see_under}
    #end
    #it "should handle an italicized space" do
      #@importer.parse("<i>HETEROMYRMEX </i>Wheeler: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    #end
    #it "should handle an author with initials" do
      #@importer.parse("<i>HETEROMYRMEX</i>Wheeler, W.M.: see under <b><i>VOLLENHOVIA</i></b>.").should == {:type => :see_under}
    #end
    #it "should handle a year after the author" do
      #@importer.parse("*<i>PALAEOMYRMEX</i> Dlussky, 1975: see under *<b><i>DLUSSKYIDRIS</i></b>").should == {:type => :see_under}
    #end
    #it "should handle a subgenus" do
      #@importer.parse(%{<i><span style="color:blue">ALAOPONE</span></i>: see under <b><i>DORYLUS</i></b>.}).should == 
        #{:type => :see_under}
    #end
    #it "should not simply consider everything with 'see under' in it as a see-under" do
      #lambda {@importer.parse("*<b>PALAEOMYRMEX</b> Dlussky, 1975: see under")}.should raise_error Citrus::ParseError
    #end
    #it "should handle a trailing comma" do
      #@importer.parse("*<i>RHOPALOMYRMEX</i>: see under <b><i>PLAGIOLEPIS</i></b>,").should == {:type => :see_under}
    #end
    #it "should handle an empty paragraph" do
      #@importer.parse("<i>DORISIDRIS</i>: see under <b><i>PYRAMICA</i></b><i><p></p></i>").should == {:type => :see_under}
    #end
    #it "should handle black" do
      #@importer.parse(%{<i><span style="color:black">PHACOTA</span></i> : see under <b><i>MONOMORIUM</i></b>.}).should == {:type => :see_under}
    #end
    #it "should handle an empty italicized paragraph" do
      #@importer.parse(%{<i>DORISIDRIS</i>: see under <b><i>PYRAMICA</i></b><i><p></p></i>}).should == {:type => :see_under}
    #end
    #it "should handle italicized period" do
      #@importer.parse(%{<i>PARVIMYRMA</i>: see under <b><i>CAREBARA</i></b><i>.</i>}).should == {:type => :see_under}
    #end

  #end

  #describe 'parsing a valid genus header' do
    #it "should recognize a valid, extant genus heading" do
      #@importer.parse("<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> (Neotropical)").should == {:type => :genus, :name => 'Acanthognathus', :status => 'valid'}
    #end
    #it "should recognize multiple regions" do
      #@importer.parse("<b><i><span style=\"color:red\">ACANTHOMYRMEX</span></i></b> (Oriental, Indo-Australian)").should == {:type => :genus, :name => 'Acanthomyrmex', :status => 'valid'}
    #end
    #it "should recognize a valid, fossil genus heading" do
      #@importer.parse("*<b><i><span style='color:red'>AFROMYRMA</span></i></b> (Botswana)").should == {:type => :genus, :name => 'Afromyrma', :fossil => true, :status => 'valid'}
    #end
    #it "should handle when Barry includes a little blank red space" do
      #@importer.parse("<b><i><span style='color:red'>ACANTHOPONERA</span></i></b><span style='color:red'> </span>(Neotropical)").should == {:type => :genus, :name => 'Acanthoponera', :status => 'valid'}
    #end
    #it "should handle a period after the genus name" do
      #@importer.parse(%{*<b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:red">ARCHIPONERA</span></i></b>. (U.S.A.)}).should == {:type => :genus, :name => 'Archiponera', :fossil => true, :status => 'valid'}
    #end
    #it "should handle a space after the genus name" do
      #@importer.parse(%{<b><i><span style="color:red">AUSTROMORIUM </span></i></b>(Australia)}).should == {:type => :genus, :name => 'Austromorium', :status => 'valid'}
    #end
    #it "should handle a space after the color" do
      #@importer.parse(%{<b><i><span style="color:red">DRYMOMYRMEX</span> </i></b>(Baltic Amber)}).should == {:type => :genus, :name => 'Drymomyrmex', :status => 'valid'}
    #end
    #it "should handle a missing paren at the end" do
      #@importer.parse(%{<b><i><span style="color:red">LEPTOMYRMEX</span></i></b> (Sulawesi, New Guinea, Australia, New Caledonia}).should == {:type => :genus, :name => 'Leptomyrmex', :status => 'valid'}
    #end
    #it "should handle a genus without a region" do
      #@importer.parse(%{<b><i><span style="color:red">NYLANDERIA</span></i></b>}).should == {:type => :genus, :name => 'Nylanderia', :status => 'valid'}
    #end
    #it "should handle superflous paragraph in its midst" do
      #@importer.parse(%{<b><i><span style="color:red">NYLANDERIA<p></p></span></i></b>}).should == {:type => :genus, :name => 'Nylanderia', :status => 'valid'}
    #end
    #it "should handle unnecessary blackness and parenthesis" do
      #@importer.parse(%{<b><i><span style="color:red">OPAMYRMA</span></i></b><span style="color:black"> (Vietnam)<p></p></span>}).should == {:type => :genus, :name => 'Opamyrma', :status => 'valid'}
    #end
    #it "should handle an unidentifiable though valid genus" do
      #@importer.parse(%{<b><i><span style='color:green'>CONDYLODON</span></i></b> (Brazil)}).should == {:type => :genus, :name => 'Condylodon', :status => 'valid'}
    #end

    #it "should handle a load of other crap" do
      #@importer.parse(%{<b><i><span style="color:red">PROMYOPIAS</span></i></b><span style="color:red"> </span><span style="color:black">(Afrotropical)<p></p></span>}).should == {:type => :genus, :name => 'Promyopias', :status => 'valid'}
    #end
    #it "should handle an empty red paragrah" do
      #@importer.parse(%{<b><i><span style="color:red">ACANTHOPONERA</span></i></b><span style="color:red"> <p></p></span>
      #}).should == {:type => :genus, :name => 'Acanthoponera', :status => 'valid'}
    #end
  #end

  #describe "parsing an unidentifiable genus header" do
    #it "should handle an ichnotaxon" do
      #@importer.parse(%{*<i><span style='color:green'>ATTAICHNUS</span></i> (ichnotaxon)}).should == {:type => :genus, :name => 'Attaichnus', :status => 'unidentifiable', :fossil => true}
    #end
    #it "should handle transferred genus" do
      #@importer.parse(%{*<i><span style="color:green">PALAEOMYRMEX</span></i> Heer, 1865: transferred to <b><i>HOMOPTERA</i></b>.}).should == {:type => :genus, :name => 'Palaeomyrmex', :status => 'unidentifiable', :fossil => true}
    #end
    #it "should handle a plain old unidentifiable genus header" do
      #@importer.parse(%{<i><span style="color:green">SCYPHODON</span></i>}).should == {:type => :genus, :name => 'Scyphodon', :status => 'unidentifiable'}
    #end
  #end

  #describe "Parsing an unresolved junior homonym genus header" do
    #it "should work" do
      #@importer.parse(%{
  #*<b style="mso-bidi-font-weight:normal"><i style="mso-bidi-font-style:normal"><span style="color:#663300">WILSONIA</span></i></b>
      #}).should == {:type => :genus, :name => 'Wilsonia', :status => 'unresolved homonym', :fossil => true}
    #end
  #end

#end
