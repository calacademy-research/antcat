# frozen_string_literal: true

require 'rails_helper'

describe AuthorDecorator do
  subject(:decorated) { author.decorate }

  describe "#published_between" do
    let(:author) { create :author }
    let(:author_name) { create :author_name, author: author }

    context "when author has no references" do
      specify { expect(decorated.published_between).to eq nil }
    end

    context "when there is a single year" do
      let!(:reference_2000) { create :any_reference, author_names: [author_name], year: 2000 }

      specify { expect(decorated.published_between).to eq reference_2000.year }
    end

    context "when there are two different years" do
      before do
        create :any_reference, author_names: [author_name], year: 2000
        create :any_reference, author_names: [author_name], year: 2010
      end

      specify { expect(decorated.published_between).to eq "2000–2010" }
    end
  end

  describe "#taxon_descriptions_between" do
    let(:author) { create :author }
    let(:author_name) { create :author_name, author: author }

    context "when author has no described taxa" do
      specify { expect(decorated.taxon_descriptions_between).to eq nil }
    end

    context "when there is a single year" do
      let(:reference_2000) { create :any_reference, author_names: [author_name], year: 2000 }

      before do
        create :any_taxon, protonym: create(:protonym, authorship_reference: reference_2000)
      end

      specify { expect(decorated.taxon_descriptions_between).to eq reference_2000.year }
    end

    context "when there are two different years" do
      let!(:reference_2000) { create :any_reference, author_names: [author_name], year: 2000 }
      let!(:reference_1990) { create :any_reference, author_names: [author_name], year: 1990 }

      before do
        create :any_taxon, protonym: create(:protonym, authorship_reference: reference_2000)
        create :any_taxon, protonym: create(:protonym, authorship_reference: reference_1990)
      end

      specify { expect(decorated.taxon_descriptions_between).to eq "1990–2000" }
    end
  end
end
