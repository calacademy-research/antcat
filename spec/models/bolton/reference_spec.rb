require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new :authors => 'Allred, D.M.', :title => "Ants of Utah", :year => 1982
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah."
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory :bolton_reference, :citation_year => '1910a'
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory :bolton_reference, :citation_year => '1910a ["1958"]'
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe 'implementing ReferenceComparable' do
    it 'should map all fields correctly' do
      @bolton = Bolton::Reference.create! :authors => 'Fisher, B. L.', :citation_year => '1981', :title => 'Dolichoderinae',
        :reference_type => 'ArticleReference', :series_volume_issue => '1(2)', :pagination => '22-54'
      @bolton.author.should == 'Fisher'
      @bolton.year.should == 1981
      @bolton.title.should == 'Dolichoderinae'
      @bolton.type.should == 'ArticleReference'
      @bolton.series_volume_issue.should == '1(2)'
      @bolton.pagination.should == '22-54'
    end
  end

  describe 'with_possible_matches' do
    it 'should not blow up' do
      Bolton::Reference.with_possible_matches
    end
  end

end
