class JournalObserver < ActiveRecord::Observer

  def before_update journal
    Reference.joins(:journal).where('journals.id = ?', journal.id).each do |reference|
      reference.invalidate_formatted_reference_cache
    end
  end

end

