# coding: UTF-8
require 'spec_helper'

describe PublisherObserver do
  describe "Invalidating the formatted reference cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      publisher = FactoryGirl.create :publisher, name: 'Barnes & Noble'
      expect_any_instance_of(PublisherObserver).to receive :before_update
      publisher.name = 'Istanbul'
      publisher.save!
    end

    it "should invalidate the cache for the references that use the publisher" do
      publisher = FactoryGirl.create :publisher
      references = []
      (0..2).each do |i|
        if i < 2
          references[i] = FactoryGirl.create :book_reference, publisher: publisher
        else
          references[i] = FactoryGirl.create :book_reference
        end
        ReferenceFormatterCache.instance.populate references[i]
      end

      expect(references[0].formatted_cache).not_to be_nil
      expect(references[1].formatted_cache).not_to be_nil
      expect(references[2].formatted_cache).not_to be_nil

      PublisherObserver.instance.before_update publisher

      expect(references[0].reload.formatted_cache).to be_nil
      expect(references[1].reload.formatted_cache).to be_nil
      expect(references[2].reload.formatted_cache).not_to be_nil
    end
  end

end
