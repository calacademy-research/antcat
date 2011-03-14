require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  it "should recognize the usual supersubfamily header" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE<o:p></o:p></span></b>
    }).should == {:type => :supersubfamily_header}
  end

  it "should recognize the supersubfamily header when there's only one subfamily" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>THE MYRMICOMORPHS: SUBFAMILY MYRMICINAE<o:p></o:p></span></b></p>
    }).should == {:type => :supersubfamily_header}
  end

  it "should recognize the supersubfamily header for extinct subfamilies" do
    @subfamily_catalog.parse(%{
<b><span lang=EN-GB>EXTINCT SUBFAMILIES OF FORMICIDAE: *ARMANIINAE, *BROWNIMECIINAE, *FORMICIINAE, *SPHECOMYRMINAE<o:p></o:p></span></b>
    }).should == {:type => :supersubfamily_header}
  end

end
