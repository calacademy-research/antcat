class Feed
  class_attribute :enabled # TODO probably not thread-safe

  def self.enabled?
    enabled != false
  end
end
