require 'spec_helper'

describe Rank do
  it "should do all these ranks" do
    [
      [:family, "family"],
      [:subfamily, "subfamily"],
      [:tribe, "tribe"], [:genus, "genus"],
      [:species, "species"],
      [:subspecies, "subspecies"]
    ].each do |symbol, string|
      expect(Rank[symbol].to_s).to eq(string)
    end
  end

  it "ex #to_class replacement code proof of concept" do
    expect(Rank[:genus].to_s.capitalize.constantize).to eq(Genus)
  end

  it "should return a string" do
    expect(Rank[:tribes].to_s).to eq('tribe')
  end

  it "ex #display_string replacement code proof of concept" do
    expect(Rank[:tribes].to_s.titlecase).to eq('Tribe')
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

  it "ex #write_selector replacement code proof of concept" do
    expect("#{Rank[create_genus].to_s}=".to_sym).to eq(:genus=)
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
