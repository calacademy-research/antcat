class PublisherObserver < ActiveRecord::Observer
  def before_update publisher
    Reference.joins(:publisher).where('publishers.id = ?', publisher.id).each do |reference|
      ReferenceFormatterCache.instance.invalidate reference
    end
  end
end
