require 'spec_helper'

describe Citation do
  it { should be_versioned }

  it "has a Reference" do
    reference = create :reference
    citation = Citation.create! reference: reference

    expect(citation.reload.reference).to eq reference
  end

  it "requires a Reference" do
    citation = Citation.create
    expect(citation.reference).to be_nil
    expect(citation).not_to be_valid
  end
end
