require 'spec_helper'

describe Parsers::CitationParser do
  subject(:parser) { described_class }

  it "returns an empty string if the string is empty" do
    ['', nil].each { |string| expect(parser.parse(string)).to be_nil }
  end

  it "handles an author + year" do
    string = 'Fisher, 2010'
    expect(parser.parse(string)).to be_truthy
    expect(string).to be_empty
  end

  it "stops after the year" do
    string = 'Santschi, 1936 (<b>unavailable name</b>);'
    expect(parser.parse(string)).to be_truthy
    expect(string).to eq '(<b>unavailable name</b>);'
  end

  it "handles multiple authors" do
    string = 'Espadaler & DuMerle, 1989: 121'
    expect(parser.parse(string)).to be_truthy
    expect(string).to be_empty
  end

  it "handles a missing comma before the year" do
    string = 'Espadaler 1989: 121'
    expect(parser.parse(string)).to be_truthy
    expect(string).to be_empty
  end

  it "handles a letter at the end of the year" do
    string = 'Espadaler 1989b: 121'
    expect(parser.parse(string)).to be_truthy
    expect(string).to be_empty
  end

  it "handles a nested citation, and an author with two last names" do
    string = 'De Andrade, in Baroni Urbani & De Andrade, 2007'
    expect(parser.parse(string)).to be_truthy
    expect(string).to be_empty
  end

  it "handles a page number" do
    string = 'Wheeler, W.M. 1915h: 142; see under *<i>pumilus</i>, above.'
    expect(parser.parse(string)).to be_truthy
    expect(string).to eq '; see under *<i>pumilus</i>, above.'
  end
end
