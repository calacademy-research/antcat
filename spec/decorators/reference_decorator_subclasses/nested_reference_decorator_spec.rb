# frozen_string_literal: true

require 'rails_helper'

describe NestedReferenceDecorator do
  describe '#pdf_link' do
    context 'when reference has a document' do
      let(:reference_document) { build(:reference_document) }
      let(:reference) { build :nested_reference }

      it 'links it' do
        expect(reference).to receive(:document).and_return(reference_document)
        expect(reference).to receive(:downloadable?).and_return(true)
        expect(reference_document).to receive(:url).and_return('reference.com')
        expect(reference.decorate.pdf_link).to eq '<a class="external-link" href="reference.com">PDF</a>'
      end
    end

    context 'when reference does not have a document' do
      context 'when parent reference has a document' do
        let(:parent_reference_document) { build(:reference_document) }
        let(:parent_reference) { build :book_reference }
        let(:reference) { build :nested_reference, nesting_reference: parent_reference }

        it "fallbacks to the parent's reference document" do
          expect(reference).to receive(:downloadable?).and_return(false)
          expect(parent_reference).to receive(:downloadable?).and_return(true)
          expect(parent_reference).to receive(:document).and_return(parent_reference_document)
          expect(parent_reference_document).to receive(:url).and_return('parent-reference.com')
          expect(reference.decorate.pdf_link).to eq '<a class="external-link" href="parent-reference.com">PDF</a>'
        end
      end
    end
  end
end
