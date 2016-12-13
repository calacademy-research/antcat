require 'spec_helper'

describe ReferenceMatcher do
  before do
    @matcher = ReferenceMatcher.new
    @match = create :reference, author_names: [create(:author_name, name: 'Ward')]
    @target = ComparableReference.new principal_author_last_name_cache: 'Ward'
  end

  it "doesn't match an obvious mismatch" do
    expect(@target).to receive(:<=>).and_return 0.00
    results = @matcher.match @target
    expect(results).to be_empty
  end

  it "matches an obvious match" do
    expect(@target).to receive(:<=>).and_return 0.10
    results = @matcher.match @target
    expect(results).to eq [{similarity: 0.10, target: @target, match: @match}]
  end

  it "handles an author last name with an apostrophe in it (regression)" do
    @match.update author_names: [create(:author_name, name: "Arnol'di, G.")]
    @target.principal_author_last_name_cache = "Arnol'di"
    expect(@target).to receive(:<=>).and_return 0.10

    results = @matcher.match @target
    expect(results).to eq [{similarity: 0.10, target: @target, match: @match}]
  end
end
