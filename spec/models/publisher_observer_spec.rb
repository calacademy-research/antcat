# coding: UTF-8
require 'spec_helper'

describe PublisherObserver do
  describe "Invalidating the formatted reference cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      publisher = FactoryGirl.create :publisher, name: 'Barnes & Noble'
      PublisherObserver.any_instance.should_receive :before_update
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
        references[i].populate_cache
      end

      references[0].formatted_cache.should_not be_nil
      references[1].formatted_cache.should_not be_nil
      references[2].formatted_cache.should_not be_nil

      PublisherObserver.instance.before_update publisher

      references[0].reload.formatted_cache.should be_nil
      references[1].reload.formatted_cache.should be_nil
      references[2].reload.formatted_cache.should_not be_nil
    end
  end

end
