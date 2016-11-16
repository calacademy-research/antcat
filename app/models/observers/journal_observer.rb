class JournalObserver < ActiveRecord::Observer
  def before_update journal
    journal.references.each &:invalidate_caches
  end
end
