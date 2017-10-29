class Feed
  class_attribute :enabled # TODO probably not thread-safe

  def self.enabled?
    enabled != false
  end

  def self.without_tracking &block
    with_or_without_tracking false, &block
  end

  def self.with_tracking &block
    with_or_without_tracking true, &block
  end

  private
    def self.with_or_without_tracking value
      before = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = before
    end
    private_class_method :with_or_without_tracking
end
