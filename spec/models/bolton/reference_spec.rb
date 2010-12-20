require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new(:authors => 'Allred, D.M.', :title => "Ants of Utah", :year => 1982)
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah."
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory(:bolton_reference, :citation_year => '1910a')
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory(:bolton_reference, :citation_year => '1910a ["1958"]')
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe 'last name of principal author' do
    it 'should work' do
      Bolton::Reference.new(:authors => 'Bolton, B.').principal_author_last_name.should == 'Bolton'
    end
  end

end
