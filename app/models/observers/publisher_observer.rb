class PublisherObserver < ActiveRecord::Observer
  def before_update publisher
    publisher.references.each do |reference|
      ReferenceFormatterCache.instance.invalidate reference
    end
  end
end
