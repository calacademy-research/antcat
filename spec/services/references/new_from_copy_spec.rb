# frozen_string_literal: true

require 'rails_helper'

describe References::NewFromCopy do
  describe '#call' do
    describe 'copying common attributes' do
      let!(:reference) { create :article_reference, :with_notes }

      specify do
        copy = described_class[reference]

        [
          :author_names_string_cache,
          :citation_year,
          :title,
          :pagination,
          :public_notes,
          :editor_notes,
          :taxonomic_notes
        ].each do |attribute|
          expect(copy.public_send(attribute)).to eq reference.public_send(attribute)
          expect(copy.public_send(attribute)).to_not eq nil
        end
      end
    end

    context "when reference is an `ArticleReference`" do
      let!(:reference) { create :article_reference }

      specify do
        copy = described_class[reference]

        expect(copy).to be_a ArticleReference

        expect(copy.series_volume_issue).to eq reference.series_volume_issue
        expect(copy.series_volume_issue).to_not eq nil
        expect(copy.journal).to eq reference.journal
        expect(copy.journal).to_not eq nil
      end
    end

    context "when reference is a `BookReference`" do
      let!(:reference) { create :book_reference }

      specify do
        copy = described_class[reference]

        expect(copy).to be_a BookReference

        expect(copy.publisher).to eq reference.publisher
        expect(copy.publisher).to_not eq nil
      end
    end

    context "when reference is a `NestedReference`" do
      let!(:reference) { create :nested_reference }

      specify do
        copy = described_class[reference]

        expect(copy).to be_a NestedReference

        expect(copy.pagination).to eq reference.pagination
        expect(copy.pagination).to_not eq nil
        expect(copy.nesting_reference_id).to eq reference.nesting_reference_id
        expect(copy.nesting_reference_id).to_not eq nil
      end
    end

    context "when reference has a document" do
      let!(:reference) { create :any_reference, :with_document }

      it 'does not copy the document' do
        copy = described_class[reference]

        expect(copy.document).to eq nil
      end
    end
  end
end
