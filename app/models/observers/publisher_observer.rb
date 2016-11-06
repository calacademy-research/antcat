class PublisherObserver < ActiveRecord::Observer
  def before_update publisher
    publisher.references.each &:invalidate
  end
end
