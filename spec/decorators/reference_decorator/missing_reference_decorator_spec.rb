require 'spec_helper'

describe MissingReferenceDecorator do
  describe "#plain_text" do
    describe "italicizing title and citation" do
      it "doesn't escape et al. in citation for a missing reference" do
        reference = create :missing_reference,
          author_names: [],
          citation_year: '2010',
          citation: 'Ants <i>et al.</i>',
          title: 'Tapinoma'
        expect(reference.decorate.plain_text).to eq "2010. Tapinoma. Ants <i>et al.</i>."
      end
    end
  end

  describe "#format_reference_document_link" do
    let(:reference) { build_stubbed :missing_reference, citation: "citation" }

    specify { expect(reference.decorate.format_reference_document_link).to be_nil }
  end
end
