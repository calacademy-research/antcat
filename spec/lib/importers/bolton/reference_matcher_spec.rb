# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::ReferenceMatcher do
  before do
    @matcher = Importers::Bolton::ReferenceMatcher.new
    @match = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Ward')]
    @target = ComparableReference.new :author => 'Ward'
  end

  it "should not match an obvious mismatch" do
    expect(@target).to receive(:<=>).and_return 0.00
    results = @matcher.match @target
    expect(results[:matches]).to be_empty
    expect(results[:similarity]).to be_zero
  end

  it "should match an obvious match" do
    expect(@target).to receive(:<=>).and_return 0.10
    results = @matcher.match @target
    expect(results[:matches]).to eq([{:similarity => 0.10, :target => @target, :match => @match}])
    expect(results[:similarity]).to eq(0.10)
  end

  it "should handle an author last name with an apostrophe in it (regression)" do
    @match.update_attributes :author_names => [FactoryGirl.create(:author_name, :name => "Arnol'di, G.")]
    @target.author = "Arnol'di"
    expect(@target).to receive(:<=>).and_return 0.10

    results = @matcher.match @target
    expect(results[:matches]).to eq([{:similarity => 0.10, :target => @target, :match => @match}])
    expect(results[:similarity]).to eq(0.10)
  end

  it "should only save the highest similarity results as matches" do
    author_names = [FactoryGirl.create(:author_name, :name => 'Ward, P. S.')]
    Reference.delete_all
    expect(@target).to receive(:<=>).with(FactoryGirl.create :reference, :author_names => author_names).and_return 0.50
    expect(@target).to receive(:<=>).with(FactoryGirl.create :reference, :author_names => author_names).and_return 0.00
    expect(@target).to receive(:<=>).with(FactoryGirl.create :reference, :author_names => author_names).and_return 0.50
    expect(@target).to receive(:<=>).with(FactoryGirl.create :reference, :author_names => author_names).and_return 0.10
    results = @matcher.match @target
    expect(results[:matches].map {|e| e[:similarity]}).to eq([0.50, 0.50])
    expect(results[:similarity]).to eq(0.50)
  end

end
