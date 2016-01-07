require 'spec_helper'

describe Hol::Reference do

  it "should be possible to set its attributes via a hash" do
    reference = Hol::Reference.new :document_url => 'a source', :year => '2010', :series_volume_issue => '1', :pagination => '2-3'
    expect(reference.document_url).to eq('a source')
    expect(reference.year).to eq('2010')
    expect(reference.series_volume_issue).to eq('1')
    expect(reference.pagination).to eq('2-3')
  end

  it "should be comparable" do
    expect(Hol::Reference.new(:author => 'Bolton')).to be_kind_of ComparableReference
  end

end
