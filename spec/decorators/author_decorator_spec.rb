# frozen_string_literal: true

require 'rails_helper'

describe AuthorDecorator do
  let(:author) { create :author }
  let(:author_name) { create :author_name, author: author }

  describe "#published_between" do
    context "when author has no references" do
      specify { expect(author.decorate.published_between).to eq nil }
    end

    context "when author has references" do
      let!(:reference) { create :any_reference, author_names: [author_name], citation_year: 2000 }

      context "when start and end year are the same" do
        specify { expect(author.decorate.published_between).to eq reference.year }
      end

      context "when start and end year are not the same" do
        before do
          create :any_reference, author_names: [author_name], citation_year: 2010
        end

        specify { expect(author.decorate.published_between).to eq "2000–2010" }
      end
    end
  end

  describe "#taxon_descriptions_between" do
    context "when author has no described taxa" do
      specify { expect(author.decorate.taxon_descriptions_between).to eq nil }
    end

    context "when there are two years" do
      let!(:reference) { create :any_reference, author_names: [author_name], citation_year: 2000 }

      before do
        create(:species).protonym.authorship.update!(reference: reference)
      end

      context "when start and end year are the same" do
        specify { expect(author.decorate.taxon_descriptions_between).to eq reference.year }
      end

      context "when start and end year are not the same" do
        before do
          second_reference = create :any_reference, author_names: [author_name], citation_year: 1990
          create(:any_taxon).protonym.authorship.update!(reference: second_reference)

          old_reference = create :any_reference, author_names: [author_name], citation_year: 1980
          create(:any_taxon).protonym.authorship.update!(reference: old_reference)
        end

        specify { expect(author.decorate.taxon_descriptions_between).to eq "1980–2000" }
      end
    end
  end
end
