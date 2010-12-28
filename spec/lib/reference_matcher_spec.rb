require 'spec_helper'

describe ReferenceMatcher do
  before do
    @matcher = ReferenceMatcher.new
    @match = Factory :reference, :author_names => [Factory :author_name, :name => 'Ward']
    @target = ComparableReference.new :author => 'Ward'
  end

  it "should not match an obvious mismatch" do
    @target.should_receive(:<=>).and_return 0
    results = @matcher.match @target
    results[:matches].should be_empty
    results[:confidence].should be_zero
  end

  it "should match an obvious match" do
    @target.should_receive(:<=>).and_return 1
    results = @matcher.match @target
    results[:matches].should == [{:confidence => 1, :target => @target.id, :match => @match.id}]
    results[:confidence].should == 1
  end
    
  it "should handle an author last name with an apostrophe in it (regression)" do
    @match.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
    @target.author = "Arnol'di"
    @target.should_receive(:<=>).and_return 1

    results = @matcher.match @target
    results[:matches].should == [{:confidence => 1, :target => @target.id, :match => @match.id}]
    results[:confidence].should == 1
  end

  it "should only save the highest confidence results as matches" do
    author_names = [Factory :author_name, :name => 'Ward, P. S.']
    Reference.delete_all
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 0
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
    @target.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 1
    results = @matcher.match @target
    results[:matches].map {|e| e[:confidence]}.should == [50, 50]
    results[:confidence].should == 50
  end

end
