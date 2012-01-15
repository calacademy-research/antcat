# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  it "should recognize the usual supersubfamily header" do
    @importer.parse(%{
<b><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE<o:p></o:p></span></b>
    }).should == {type: :supersubfamily_header}
  end

  it "should recognize the supersubfamily header when there's only one subfamily" do
    @importer.parse(%{
<b><span lang=EN-GB>THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>
    }).should == {type: :supersubfamily_header}
  end

  it "should recognize the supersubfamily header for extinct subfamilies" do
    @importer.parse(%{
<b><span lang=EN-GB>EXTINCT SUBFAMILIES OF FORMICIDAE: *ARMANIINAE, *BROWNIMECIINAE, *FORMICIINAE, *SPHECOMYRMINAE<o:p></o:p></span></b>
    }).should == {type: :supersubfamily_header}
  end

end
