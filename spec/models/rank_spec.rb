require 'spec_helper'

describe Rank do
  it "should do all these ranks" do
    [[:family, Family], [:subfamily, Subfamily], [:tribe, Tribe], [:genus, Genus], [:species, Species], [:subspecies, Subspecies]].each do |symbol, klass|
      expect(Rank[symbol].to_class).to eq(klass)
    end
  end
  it "should convert a symbol to a klass" do
    expect(Rank[:genus].to_class).to eq(Genus)
  end
  it "should convert a klass to a symbol" do
    expect(Rank[:genus].to_sym).to eq(:genus)
  end
  it "should return a string" do
    expect(Rank[:tribes].to_s).to eq('tribe')
  end
  it "should have a display string" do
    expect(Rank[:tribes].display_string).to eq('Tribe')
  end
  it "should do caps" do
    expect(Rank[:tribes].to_s(:capitalized)).to eq('Tribe')
  end
  it "should do caps plural" do
    expect(Rank[:tribes].to_s(:capitalized, :plural)).to eq('Tribes')
  end
  it "should do plural symbol" do
    expect(Rank['Genera'].to_sym(:plural)).to eq(:genera)
  end
  it "should convert from a taxon to a symbol" do
    expect(Rank[Genus.new].to_sym).to eq(:genus)
  end
  it "should automatically singularize or pluralize depending on a count" do
    expect(Rank[Genus.new].to_s(1)).to eq('genus')
    expect(Rank[Genus.new].to_s(2)).to eq('genera')
  end
  it "should convert from an array of taxa" do
    expect(Rank[[Genus.new]].to_s).to eq('genus')
  end
  it "should convert from an ActiveRecord relation" do
    FactoryGirl.create :genus
    expect(Rank[Genus.first.subfamily].to_s).to eq('subfamily')
  end
  it "should convert from an ActiveRecord relation" do
    FactoryGirl.create :genus
    expect(Rank[Genus.first].to_s).to eq('genus')
  end
  it "should raise an error if it doesn't understand the input" do
    expect {Rank['asdf']}.to raise_error
  end
  it "should understand write_selector" do
    expect(Rank[create_genus].write_selector).to eq(:genus=)
  end
  it "should understand read_selector" do
    expect(Rank[create_species].read_selector).to eq(:species)
  end
  it "should understand its parent" do
    expect(Rank[create_subspecies('Atta major minor')].parent).to eq(Rank[:species])
    expect(Rank[create_species].parent).to eq(Rank[:genus])
    expect(Rank[create_genus].parent).to eq(Rank[:subfamily])
    expect(Rank[create_subfamily].parent).to eq(Rank[:family])
    expect(Rank[create_family].parent).to be_nil
  end
  it "should understand its child" do
    expect(Rank[create_subspecies('Atta major minor')].child).to be_nil
    expect(Rank[create_family].child).to eq(Rank[:subfamily])
  end
  it "should handle nil and blank OK" do
    expect(Rank['']).to be_nil
    expect(Rank[nil]).to be_nil
  end
end
