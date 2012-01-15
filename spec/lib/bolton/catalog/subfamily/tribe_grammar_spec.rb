# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Junior synonyms of tribe header" do

    it "should be recognized" do
      @importer.parse(%{
<b><span lang=EN-GB>Junior synonym of <span style='color:red'>ECTATOMMINI<o:p></o:p></span></span></b>
      }).should == {type: :junior_synonyms_of_tribe_header}
    end

    it "should be recognized when plural" do
      @importer.parse(%{
<b><span lang="EN-GB">Junior synonyms of <span style="color:red">LEPTOMYRMECINI</span><p></p></span></b>
      }).should == {type: :junior_synonyms_of_tribe_header}
    end

  end

  describe "Genera incertae sedis in tribe" do

    it "should be recognized" do
      @importer.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>Heteroponerini</span><o:p></o:p></span></b>
      }).should == {type: :genera_incertae_sedis_in_tribe_header}
    end

  end
end
