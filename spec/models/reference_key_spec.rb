# coding: UTF-8
require 'spec_helper'

describe ReferenceKey do
  it "should output a <ref xxx> for Text" do
    reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton, B.')], :citation_year => '1970a'
    ReferenceKey.new(reference).to_text.should == "<ref #{reference.id}>"
  end

  describe "Link" do
    #it "should create a link to the reference" do
      #reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, P. A.')], :citation_year => '1809'
      #reference.key.to_link.should ==  "<a class=\"reference_key\" href=\"/references?q=#{reference.id}\">Latreille, 1809</a>"
    #end
  end

end
