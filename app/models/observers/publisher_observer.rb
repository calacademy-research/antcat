class PublisherObserver < ActiveRecord::Observer
  def before_update publisher
    publisher.references.each &:invalidate_caches
  end
end
