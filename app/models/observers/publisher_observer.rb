class PublisherObserver < ActiveRecord::Observer
  def before_update publisher
    publisher.references.find_each &:invalidate_caches
  end
end
