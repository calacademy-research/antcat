require 'spec_helper'

describe ReferenceObserver do
  let(:reference) { create :article_reference }

  describe "nested references" do
    context "when a nesting_reference is changed" do
      let(:nestee) { create :nested_reference, nesting_reference: reference }

      before do
        reference.reload
        nestee.reload
        ReferenceFormatterCache.populate reference
        ReferenceFormatterCache.populate nestee
      end

      it "invalidates the cache for itself and its nestees" do
        expect(reference.formatted_cache).to_not be_nil
        expect(nestee.formatted_cache).to_not be_nil

        reference.update! title: "New Title"

        expect(reference.reload.formatted_cache).to be_nil
        expect(nestee.reload.formatted_cache).to be_nil
      end
    end
  end

  context "when a reference document is changed" do
    let(:reference_document) { create :reference_document, reference: reference }

    before do
      reference.reload
      ReferenceFormatterCache.populate reference
    end

    it "invalidates the cache for the document's reference" do
      expect { described_class.instance.before_update reference }
        .to change { reference.reload.formatted_cache.nil? }.from(false).to(true)
    end
  end
end
