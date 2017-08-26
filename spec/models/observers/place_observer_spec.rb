require 'spec_helper'

describe PlaceObserver do
  let(:place) { create :place, name: 'Constantinople' }

  context "when a place is changed" do
    it "is notified" do
      expect_any_instance_of(described_class).to receive :before_update
      place.name = 'Istanbul'
      place.save!
    end

    it "invalidates the cache for the references that use the place" do
      publisher = create :publisher, place: place
      references = [ create(:book_reference, publisher: publisher),
                     create(:book_reference, publisher: publisher),
                     create(:book_reference) ]

      references.each { |reference| ReferenceFormatterCache.populate reference }
      references.each { |reference| expect(reference.formatted_cache).not_to be_nil }

      described_class.instance.before_update place

      expect(references[0].reload.formatted_cache).to be_nil
      expect(references[1].reload.formatted_cache).to be_nil
      expect(references[2].reload.formatted_cache).not_to be_nil
    end
  end
end
