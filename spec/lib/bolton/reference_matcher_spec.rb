require 'spec_helper'

describe Bolton::ReferenceMatcher do
  before do
    @matcher = Bolton::ReferenceMatcher.new
    @match = Factory :reference, :author_names => [Factory(:author_name, :name => 'Ward')]
    @target = ComparableReference.new :author => 'Ward'
  end

  it "should not match an obvious mismatch" do
    @target.should_receive(:<=>).and_return 0.00
    results = @matcher.match @target
    results[:matches].should be_empty
    results[:similarity].should be_zero
  end

  it "should match an obvious match" do
    @target.should_receive(:<=>).and_return 0.10
    results = @matcher.match @target
    results[:matches].should == [{:similarity => 0.10, :target => @target, :match => @match}]
    results[:similarity].should == 0.10
  end
    
  it "should handle an author last name with an apostrophe in it (regression)" do
    @match.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
    @target.author = "Arnol'di"
    @target.should_receive(:<=>).and_return 0.10

    results = @matcher.match @target
    results[:matches].should == [{:similarity => 0.10, :target => @target, :match => @match}]
    results[:similarity].should == 0.10
  end

  it "should only save the highest similarity results as matches" do
    author_names = [Factory(:author_name, :name => 'Ward, P. S.')]
    Reference.delete_all
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 0.50
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 0.00
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 0.50
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 0.10
    results = @matcher.match @target
    results[:matches].map {|e| e[:similarity]}.should == [0.50, 0.50]
    results[:similarity].should == 0.50
  end

end
