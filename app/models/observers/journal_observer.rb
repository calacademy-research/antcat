class JournalObserver < ActiveRecord::Observer
  def before_update journal
    journal.references.each do |reference|
      ReferenceFormatterCache.instance.invalidate reference
    end
  end
end
