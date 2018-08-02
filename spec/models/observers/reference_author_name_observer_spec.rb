require 'spec_helper'

describe ReferenceAuthorNameObserver do
  let(:reference) { create :article_reference }

  context "when a reference_author_name is changed" do
    it "is notified" do
      author_name = create :author_name
      reference_author_name = create :reference_author_name, reference: reference, author_name: author_name
      expect_any_instance_of(described_class).to receive :before_save
      reference_author_name.position = 4
      reference_author_name.save!
    end

    it "invalidates the cache for the reference involved" do
      # Setup.
      reference.reference_author_names.create! position: 1, author_name: create(:author_name)
      References::Cache::Regenerate[reference]
      reference.reload
      expect(reference.plain_text_cache).not_to be_nil

      # Act and test.
      reference.reference_author_names.first.update_attribute :position, 1000
      reference.reload
      expect(reference.plain_text_cache).to be_nil
    end

    context "when a reference_author_name is added" do
      it "invalidates the cache for the reference involved" do
        # Setup.
        References::Cache::Regenerate[reference]
        reference.reload
        expect(reference.plain_text_cache).not_to be_nil

        # Act and test.
        reference.reference_author_names.create! position: 1, author_name: create(:author_name)
        reference.reload
        expect(reference.plain_text_cache).to be_nil
      end
    end

    context "when a reference_author_name is deleted" do
      it "invalidates the cache for the reference involved " do
        # Setup.
        reference.reference_author_names.create! position: 1, author_name: create(:author_name)
        References::Cache::Regenerate[reference]
        reference.reload
        expect(reference.plain_text_cache).not_to be_nil

        # Act and test.
        reference.reference_author_names.first.destroy
        reference.reload
        expect(reference.plain_text_cache).to be_nil
      end
    end
  end
end
