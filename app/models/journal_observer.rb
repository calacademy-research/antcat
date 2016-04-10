class JournalObserver < ActiveRecord::Observer

  def before_update journal
    Reference.joins(:journal).where('journals.id = ?', journal.id).each do |reference|
      ReferenceFormatterCache.instance.invalidate reference
    end
  end

end

