require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Subgenus grammar" do
    describe "Subgenera header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Subgenera of <i><span style='color:red'>MYRMOTERAS</span></i> include the nominal plus the following.<o:p></o:p></span></b></p>
        }).should == {:type => :subgenera_header}
      end

    end

    describe "Subgenus header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
  <b><span lang="EN-GB">Subgenus <i><span style="color:red">STIGMACROS (MYAGROTERAS)</span></i> <p></p></span></b>
        }).should == {:type => :subgenus_header, :name => 'Myagroteras'}
      end

    end

    describe "Junior synonyms of subgenus header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Junior synonyms of <i><span style='color:red'>STIGMACROS (MYAGROTERAS)</span></i></span></b><span lang=EN-GB style='color:red'><o:p></o:p></span>
        }).should == {:type => :junior_synonyms_of_subgenus_header}
      end

    end
  end
end
