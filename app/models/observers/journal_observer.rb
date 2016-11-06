class JournalObserver < ActiveRecord::Observer
  def before_update journal
    journal.references.each &:refresh_author_names_caches
  end
end
