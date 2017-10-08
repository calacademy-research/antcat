require 'spec_helper'

describe PublisherObserver do
  let(:publisher) { create :publisher, name: 'Barnes & Noble' }

  context "when a publisher is changed" do
    it "is notified" do
      expect_any_instance_of(described_class).to receive :before_update
      publisher.name = 'Istanbul'
      publisher.save!
    end

    it "invalidates the cache for the references that use the publisher" do
      references = [ create(:book_reference, publisher: publisher),
                     create(:book_reference, publisher: publisher),
                     create(:book_reference) ]

      references.each { |reference| References::Cache::Regenerate[reference] }
      references.each { |reference| expect(reference.formatted_cache).not_to be_nil }

      described_class.instance.before_update publisher

      expect(references[0].reload.formatted_cache).to be_nil
      expect(references[1].reload.formatted_cache).to be_nil
      expect(references[2].reload.formatted_cache).not_to be_nil
    end
  end
end
