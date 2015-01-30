# coding: UTF-8
require 'spec_helper'

describe JournalObserver do
  describe "Invalidating the formatted reference cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      journal = FactoryGirl.create :journal, name: 'Science'
      expect_any_instance_of(JournalObserver).to receive :before_update
      journal.name = 'Nature'
      journal.save!
    end

    it "should invalidate the cache for the references that use the journal" do
      journal = FactoryGirl.create :journal
      references = []
      (0..2).each do |i|
        if i < 2
          references[i] = FactoryGirl.create :book_reference, journal: journal
        else
          references[i] = FactoryGirl.create :book_reference
        end
        ReferenceFormatterCache.instance.populate references[i]
      end

      expect(references[0].formatted_cache).not_to be_nil
      expect(references[1].formatted_cache).not_to be_nil
      expect(references[2].formatted_cache).not_to be_nil

      JournalObserver.instance.before_update journal

      expect(references[0].reload.formatted_cache).to be_nil
      expect(references[1].reload.formatted_cache).to be_nil
      expect(references[2].reload.formatted_cache).not_to be_nil
    end
  end
end
