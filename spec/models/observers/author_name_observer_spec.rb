require 'spec_helper'

describe AuthorNameObserver do
  let(:bolton) { create :author_name, name: 'Bolton' }

  context "when an author name is changed" do
    it "is notified" do
      expect_any_instance_of(described_class).to receive :after_update
      bolton.name = 'Fisher'
      bolton.save!
    end

    it "invalidates the cache for all references that use the data" do
      fisher = create :author_name, name: 'Fisher'

      fisher_reference = create :article_reference, author_names: [fisher]
      References::Cache::Regenerate[fisher_reference]
      expect(fisher_reference.reload.plain_text_cache).not_to be_nil

      bolton_reference1 = create :article_reference, author_names: [bolton]
      References::Cache::Regenerate[bolton_reference1]
      expect(bolton_reference1.reload.plain_text_cache).not_to be_nil

      bolton_reference2 = create :article_reference, author_names: [bolton]
      References::Cache::Regenerate[bolton_reference2]
      expect(bolton_reference2.reload.plain_text_cache).not_to be_nil

      described_class.instance.after_update bolton

      expect(bolton_reference1.reload.plain_text_cache).to be_nil
      expect(bolton_reference2.reload.plain_text_cache).to be_nil
      expect(fisher_reference.reload.plain_text_cache).not_to be_nil
    end
  end
end
