require 'spec_helper'

describe ReferenceMatcher do
  before do
    @matcher = ReferenceMatcher.new
    @match = Factory :reference, :author_names => [Factory :author_name, :name => 'Ward']
    @target = ComparableReference.new :author => 'Ward'
  end

  it "should not match an obvious mismatch" do
    @target.should_receive(:<=>).and_return 0.00
    results = @matcher.match @target
    results.should be_empty
  end

  it "should match an obvious match" do
    @target.should_receive(:<=>).and_return 0.10
    results = @matcher.match @target
    results.should == [{:similarity => 0.10, :target => @target.id, :match => @match.id}]
  end
    
  it "should handle an author last name with an apostrophe in it (regression)" do
    @match.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
    @target.author = "Arnol'di"
    @target.should_receive(:<=>).and_return 0.10

    results = @matcher.match @target
    results.should == [{:similarity => 0.10, :target => @target.id, :match => @match.id}]
  end

end
