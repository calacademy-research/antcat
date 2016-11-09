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

  describe "#year" do
    it "shows the year" do
      reference = reference_factory author_name: 'Bolton', citation_year: '2001'
      citation = build_stubbed :citation, reference: reference

      expect(citation.year).to eq '2001'
    end

    it "handles nil years" do
      reference = reference_factory author_name: 'Bolton', citation_year: nil
      citation = build_stubbed :citation, reference: reference

      expect(citation.year).to eq "[no year]"
    end
  end
end
