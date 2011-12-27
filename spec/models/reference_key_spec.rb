# coding: UTF-8
require 'spec_helper'

describe ReferenceKey do
  it "should output a <ref xxx> for Text" do
    reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a'
    ReferenceKey.new(reference).to_text.should == "<ref #{reference.id}>"
  end

  describe "Link" do
    it "should create a link to the reference" do
      reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809', :title => "Ants", :journal => Factory(:journal, :name => 'Science'), :series_volume_issue => '(1)', :pagination => '3'
      reference.key.to_link.should ==
        "<span>" +
          "<span class=\"reference_key\">Latreille, 1809</span>" + 
          "<span class=\"reference_key_expansion\">" +
            "<span>Latreille, P. A. 1809. Ants. Science (1):3.</span>" +
            "<img src=\"/images/external_link.png\"></img>" +
          "</span>" +
        "</span>"
    end
  end

end
