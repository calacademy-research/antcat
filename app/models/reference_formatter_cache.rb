class ReferenceFormatterCache
  include Singleton

  # Extend with Forwardable to avoid typing `ReferenceFormatterCache.instance`
  class << self
    extend Forwardable
    def_delegators :instance, :invalidate, :get, :set, :populate, :set
  end

  def invalidate reference
    return if reference.new_record?

    reference.update_column :formatted_cache, nil
    reference.update_column :inline_citation_cache, nil
    reference.nestees.each &:invalidate_caches
  end

  def set reference, value, field
    # Avoid touching the database for non-persisted references (or displaying
    # reified PaperTrail versions will not work, since this method is called
    # in `ReferenceDecorator`.)
    return value unless reference.persisted?

    # Skip if cache is already up to date.
    return value if reference.send(field) == value

    reference.update_column field, value
    value
  end

  # Used in tests. Can also be manually invoked in prod/dev.
  def regenerate reference
    References::Cache::Regenerate.new(reference).call
  end
  alias_method :populate, :regenerate
end
