class ReferenceFormatterCache
  include Singleton

  # Extend with Forwardable to avoid typing `ReferenceFormatterCache.instance`
  class << self
    extend Forwardable
    def_delegators :instance, :invalidate, :get, :set, :populate, :set
  end

  # Used in tests. Can also be manually invoked in prod/dev.
  def regenerate reference
    References::Cache::Regenerate[reference]
  end
  alias_method :populate, :regenerate
end
