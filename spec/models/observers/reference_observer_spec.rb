require 'spec_helper'

describe ReferenceObserver do
  let(:reference) { create :article_reference }

  describe "nested references" do
    context "when a nesting_reference is changed" do
      let(:nestee) { create :nested_reference, nesting_reference: reference }

      before do
        reference.reload
        nestee.reload
        References::Cache::Regenerate[reference]
        References::Cache::Regenerate[nestee]
      end

      it "invalidates the cache for itself and its nestees" do
        expect(reference.formatted_cache).to_not be_nil
        expect(nestee.formatted_cache).to_not be_nil

        reference.update! title: "New Title"

        expect(reference.reload.formatted_cache).to be_nil
        expect(nestee.reload.formatted_cache).to be_nil
      end
    end

    describe "Handling a network" do
      let!(:nesting_reference) { create :article_reference }
      let!(:nested_reference) { create :nested_reference, nesting_reference: nesting_reference }
      let!(:reference_author_name) do
        create :reference_author_name, reference: nesting_reference,
          author_name: create(:author_name)
      end

      before do
        References::Cache::Regenerate[nesting_reference]
        nesting_reference.reload

        References::Cache::Regenerate[nested_reference]
        nested_reference.reload
      end

      it "invalidates each member of the network" do
        expect(nesting_reference.formatted_cache).not_to be_nil
        expect(nested_reference.formatted_cache).not_to be_nil

        reference_author_name.position = 4
        reference_author_name.save!

        nesting_reference.reload
        nested_reference.reload

        expect(nesting_reference.formatted_cache).to be_nil
        expect(nested_reference.formatted_cache).to be_nil
      end
    end
  end

  context "when a reference document is changed" do
    let(:reference_document) { create :reference_document, reference: reference }

    before do
      reference.reload
      References::Cache::Regenerate[reference]
    end

    it "invalidates the cache for the document's reference" do
      expect { described_class.instance.before_update reference }
        .to change { reference.reload.formatted_cache.nil? }.from(false).to(true)
    end
  end
end
