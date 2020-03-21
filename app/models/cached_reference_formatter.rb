# TODO: Do not cache in database.
# TODO: Cleanup. Can wait until `MissingReference` has been removed.

class CachedReferenceFormatter
  def initialize reference
    @reference = reference
  end

  def plain_text
    return References::Formatted::PlainText[reference] if ENV['NO_REF_CACHE']
    return plain_text_cache.html_safe if plain_text_cache

    References::Cache::Set[reference, References::Formatted::PlainText[reference], :plain_text_cache]
  end

  def expanded_reference
    return References::Formatted::Expanded[reference] if ENV['NO_REF_CACHE']
    return expanded_reference_cache.html_safe if expanded_reference_cache

    References::Cache::Set[reference, References::Formatted::Expanded[reference], :expanded_reference_cache]
  end

  def expandable_reference
    return References::Formatted::Expandable[reference] if ENV['NO_REF_CACHE']
    return expandable_reference_cache.html_safe if expandable_reference_cache

    References::Cache::Set[reference, References::Formatted::Expandable[reference], :expandable_reference_cache]
  end

  private

    attr_reader :reference

    delegate :plain_text_cache, :expandable_reference_cache, :expanded_reference_cache, to: :reference
end
