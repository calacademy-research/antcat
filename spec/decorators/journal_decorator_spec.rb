# frozen_string_literal: true

require 'rails_helper'

describe JournalDecorator do
  subject(:decorated) { journal.decorate }

  describe "#publications_between" do
    let(:journal) { create :journal }
    let!(:reference) { create :article_reference, citation_year: 2000, journal: journal }

    context "when start and end year are the same" do
      specify { expect(decorated.publications_between).to eq reference.year }
    end

    context "when start and end year are not the same" do
      before { create :article_reference, citation_year: 2010, journal: journal }

      specify { expect(decorated.publications_between).to eq "2000–2010" }
    end
  end
end
