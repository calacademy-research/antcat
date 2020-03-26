# frozen_string_literal: true

require 'rails_helper'

describe ReferenceDocumentObserver do
  context "when a reference document is changed" do
    it "invalidates the cache for the reference that uses the reference document" do
      # Setup.
      reference = create :article_reference
      reference_document = create :reference_document, reference: reference
      References::Cache::Regenerate[reference]
      reference.reload
      expect(reference.plain_text_cache).not_to eq nil

      # Act and test.
      described_class.instance.before_update reference_document
      expect(reference.plain_text_cache).to eq nil
    end

    context "when reference document has no associated reference" do
      let(:reference_document) { create :reference_document }

      it "doesn't croak/bork" do
        described_class.instance.before_update reference_document
      end
    end
  end
end
