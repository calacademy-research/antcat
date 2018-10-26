class JournalObserver < ActiveRecord::Observer
  def before_update journal
    journal.references.find_each &:invalidate_caches
  end
end
