require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoltonReference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = BoltonReference.new(:authors => 'Allred, D.M.', :title_and_citation =>
                                   "Ants of Utah. Great Basin Naturalist 42: 415-511", :year => '1982')
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah. Great Basin Naturalist 42: 415-511."
    end
  end

  describe "matching against ward" do
    it "should create and call a matcher" do
      matcher = mock
      BoltonReferenceMatcher.should_receive(:new).and_return(matcher)
      matcher.should_receive(:match_all)
      BoltonReference.match_against_ward
    end
  end

end
