# coding: UTF-8
require 'spec_helper'

describe Protonym do
  it "has an authorship" do
    authorship = Factory :reference_location
    protonym = Protonym.create! :authorship => authorship
    protonym.reload.authorship.should == authorship
  end

  describe "Importing" do
    it "works" do
      reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Bolton')], :citation_year => '1920'
      Reference.should_receive(:find_by_bolton_author_year).and_return reference
      authorship = {:author_names=>["Latreille"], :year=>"1809", :pages=>"124"}
      protonym = Protonym.import 'Formicariae', authorship
      protonym.name.should == 'Formicariae'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.citation_year.should == '1920'
    end
  end
end
