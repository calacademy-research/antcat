class Feed
  class_attribute :enabled # TODO probably not thread-safe

  def self.enabled?
    enabled != false
  end

  def self.without_tracking &block
    _with_or_without_tracking false, &block
  end

  def self.with_tracking &block
    _with_or_without_tracking true, &block
  end

  private
    def self._with_or_without_tracking value
      before = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = before
    end
    private_class_method :_with_or_without_tracking
end
