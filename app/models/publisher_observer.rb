class PublisherObserver < ActiveRecord::Observer

  def before_update publisher
    Reference.joins(:publisher).where('publishers.id = ?', publisher.id).each do |reference|
      reference.invalidate_formatted_reference_cache
    end
  end

end
