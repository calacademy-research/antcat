require 'spec_helper'

describe ReferenceDocumentObserver do
  context "when a reference document is changed" do
    it "is notified" do
      reference_document = create :reference_document
      expect_any_instance_of(ReferenceDocumentObserver).to receive :before_update
      reference_document.url = 'antcat.org'
      reference_document.save!
    end

    it "invalidates the cache for the reference that uses the reference document" do
      reference = create :article_reference
      reference_document = create :reference_document, reference: reference
      ReferenceFormatterCache.populate reference
      ReferenceDocumentObserver.instance.before_update reference_document

      # TODO check that is wasn't nil all the time.
      expect(reference.formatted_cache).to be_nil
    end

    context "reference document has no associated reference" do
      it "doesn't croak/bork" do
        reference_document = create :reference_document
        ReferenceDocumentObserver.instance.before_update reference_document
      end
    end
  end
end
