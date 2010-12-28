require 'spec_helper'

describe ReferenceMatcher do
  describe "matching Bolton's references against Ward's" do
    before do
      @matcher = ReferenceMatcher.new
      @ward = Factory :reference, :author_names => [Factory :author_name, :name => 'Ward']
      @bolton = Factory :bolton_reference, :authors => 'Ward'
    end

    it "should not match an obvious mismatch" do
      @bolton.should_receive(:<=>).and_return 0
      results = @matcher.match @bolton
      results[:matches].should be_empty
      results[:confidence].should be_zero
    end

    it "should match an obvious match" do
      @bolton.should_receive(:<=>).and_return 1
      results = @matcher.match @bolton
      results[:matches].should == [{:confidence => 1, :target => @bolton.id, :match => @ward.id}]
      results[:confidence].should == 1
    end
      
    it "should handle an author last name with an apostrophe in it (regression)" do
      @ward.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
      @bolton.update_attributes :authors => "Arnol'di, G."
      @bolton.should_receive(:<=>).and_return 1

      results = @matcher.match @bolton
      results[:matches].should == [{:confidence => 1, :target => @bolton.id, :match => @ward.id}]
      results[:confidence].should == 1
    end

    it "should only save the highest confidence results as matches" do
      author_names = [Factory :author_name, :name => 'Ward, P. S.']
      Reference.delete_all
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 1
      results = @matcher.match @bolton
      results[:matches].map {|e| e[:confidence]}.should == [50, 50]
      results[:confidence].should == 50
    end

  end
end
