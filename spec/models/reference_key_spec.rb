# coding: UTF-8
require 'spec_helper'

describe ReferenceKey do

  it "should output a {ref xxx} for Taxt" do
    reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a'
    ReferenceKey.new(reference).to_taxt.should == "{ref #{reference.id}}"
  end

  describe "Representing as a string" do
    it "should be blank if a new record" do
      BookReference.new.key.to_s.should == ''
    end
    it "Citation year with extra" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a ("1971")'
      reference.key.to_s.should == 'Bolton, 1970a'
    end
    it "No authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [], :citation_year => '1970a'
      reference.key.to_s.should == '[no authors], 1970a'
    end
    it "One author" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a'
      reference.key.to_s.should == 'Bolton, 1970a'
    end
    it "Two authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.'), FactoryGirl.create(:author_name, :name => 'Fisher, B.')], :citation_year => '1970a'
      reference.key.to_s.should == 'Bolton & Fisher, 1970a'
    end
    it "Three authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.'), FactoryGirl.create(:author_name, :name => 'Fisher, B.'), FactoryGirl.create(:author_name, :name => 'Ward, P.S.')], :citation_year => '1970a'
      reference.key.to_s.should == 'Bolton, Fisher & Ward, 1970a'
    end
  end

  describe "Link" do
    it "should create a link to the reference" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809', :title => "Ants", :journal => FactoryGirl.create(:journal, :name => 'Science'), :series_volume_issue => '(1)', :pagination => '3'
      user = mock
      reference.stub(:downloadable_by?).and_return true
      reference.stub(:url).and_return 'example.com'
      reference.key.to_link(nil).should ==
        "<span class=\"reference_key_and_expansion\">" +
          "<a class=\"reference_key\" href=\"#\">Latreille, 1809</a>" + 
          "<span class=\"reference_key_expansion\">" +
            "<span class=\"reference_key_expansion_text\">Latreille, P. A. 1809. Ants. Science (1):3.</span>" +
            "<a class=\"document_link\" target=\"_blank\" href=\"example.com\">PDF</a>" +
            "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{reference.id}\"><img alt=\"External_link\" src=\"/assets/external_link.png\" /></a>" +
          "</span>" +
        "</span>"
    end
    it "should create a link to the reference without the PDF link if the user isn't logged in" do
      reference = FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809', :title => "Ants", :journal => FactoryGirl.create(:journal, :name => 'Science'), :series_volume_issue => '(1)', :pagination => '3'
      reference.stub(:downloadable_by?).and_return false
      reference.key.to_link(nil).should ==
        "<span class=\"reference_key_and_expansion\">" +
          "<a class=\"reference_key\" href=\"#\">Latreille, 1809</a>" + 
          "<span class=\"reference_key_expansion\">" +
            "<span class=\"reference_key_expansion_text\">Latreille, P. A. 1809. Ants. Science (1):3.</span>" +
            "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{reference.id}\"><img alt=\"External_link\" src=\"/assets/external_link.png\" /></a>" +
          "</span>" +
        "</span>"
    end
  end

end
