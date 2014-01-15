require 'spec_helper'

describe JournalObserver do
  it "should invalidate the cache for the references that use the journal" do
    journal = FactoryGirl.create :journal
    references = []
    (0..2).each do |i|
      if i < 2
        references[i] = FactoryGirl.create :book_reference, journal: journal
      else
        references[i] = FactoryGirl.create :book_reference
      end
      references[i].populate_cache
    end

    references[0].formatted_cache.should_not be_nil
    references[1].formatted_cache.should_not be_nil
    references[2].formatted_cache.should_not be_nil

    JournalObserver.instance.before_update journal

    references[0].reload.formatted_cache.should be_nil
    references[1].reload.formatted_cache.should be_nil
    references[2].reload.formatted_cache.should_not be_nil
  end
end
