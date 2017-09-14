require "spec_helper"

describe JournalDecorator do
  let(:journal) { create :journal }
  let!(:reference) do
    create :article_reference, citation_year: 2000, journal: journal
  end

  describe "#publications_between" do
    context "when start and end year are the same" do
      specify { expect(journal.decorate.publications_between).to eq reference.year }
    end

    context "when start and end year are not the same" do
      before do
        create :article_reference, citation_year: 2010, journal: journal
      end

      specify { expect(journal.decorate.publications_between).to eq "2000&ndash;2010" }
    end
  end
end
