# coding: UTF-8
require 'spec_helper'

describe ReferenceKey do

  it "should output a {ref xxx} for Taxt" do
    reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a'
    ReferenceKey.new(reference).to_taxt.should == "{ref #{reference.id}}"
  end

  describe "Link" do
    it "should create a link to the reference" do
      reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809', :title => "Ants", :journal => Factory(:journal, :name => 'Science'), :series_volume_issue => '(1)', :pagination => '3'
      user = mock
      reference.stub(:downloadable_by?).and_return true
      reference.stub(:url).and_return 'example.com'
      reference.key.to_link(nil).should ==
        "<span class=\"reference_key_and_expansion\">" +
          "<a class=\"reference_key\" href=\"#\">Latreille, 1809</a>" + 
          "<span class=\"reference_key_expansion\">" +
            "<span class=\"reference_key_expansion_text\">Latreille, P. A. 1809. Ants. Science (1):3.</span>" +
            "<a class=\"document_link\" target=\"_blank\" href=\"example.com\">PDF</a>" +
            "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{reference.id}\"><img src=\"/images/external_link.png\"></img></a>" +
          "</span>" +
        "</span>"
    end
    it "should create a link to the reference without the PDF link if the user isn't logged in" do
      reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809', :title => "Ants", :journal => Factory(:journal, :name => 'Science'), :series_volume_issue => '(1)', :pagination => '3'
      reference.stub(:downloadable_by?).and_return false
      reference.key.to_link(nil).should ==
        "<span class=\"reference_key_and_expansion\">" +
          "<a class=\"reference_key\" href=\"#\">Latreille, 1809</a>" + 
          "<span class=\"reference_key_expansion\">" +
            "<span class=\"reference_key_expansion_text\">Latreille, P. A. 1809. Ants. Science (1):3.</span>" +
            "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{reference.id}\"><img src=\"/images/external_link.png\"></img></a>" +
          "</span>" +
        "</span>"
    end
  end

end
