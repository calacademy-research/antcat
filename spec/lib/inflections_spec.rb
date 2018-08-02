require 'spec_helper'

describe "inflections" do # rubocop:disable RSpec/DescribeClass
  it "pluralizes" do
    expect("family".pluralize).to eq "families"
    expect("subfamily".pluralize).to eq "subfamilies"
    expect("tribe".pluralize).to eq "tribes"
    expect("genus".pluralize).to eq "genera"
    expect("subgenus".pluralize).to eq "subgenera"
    expect("species".pluralize).to eq "species"
    expect("subspecies".pluralize).to eq "subspecies"
  end

  it "doesn't pluralize singulars" do
    expect("family".pluralize(1)).to eq "family"
    expect("subfamily".pluralize(1)).to eq "subfamily"
    expect("tribe".pluralize(1)).to eq "tribe"
    expect("genus".pluralize(1)).to eq "genus"
    expect("subgenus".pluralize(1)).to eq "subgenus"
    expect("species".pluralize(1)).to eq "species"
    expect("subspecies".pluralize(1)).to eq "subspecies"
  end
end
