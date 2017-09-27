require 'spec_helper'

describe MissingReferenceDecorator do
  describe "#formatted" do
    describe "italicizing title and citation" do
      it "doesn't escape et al. in citation for a missing reference" do
        reference = create :missing_reference,
          author_names: [],
          citation_year: '2010',
          citation: 'Ants <i>et al.</i>',
          title: 'Tapinoma'
        expect(reference.decorate.formatted).to eq "2010. Tapinoma. Ants <i>et al.</i>."
      end
    end
  end
end
