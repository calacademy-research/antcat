# TODO probably make this a statis class.

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

  # TODO possibly reinstate `#get` unless it's only required in specs.

  def set reference, value, field
    return value if reference.send(field) == value
    reference.update_column field, value
    value
  end

  # Used in tests. Can also be manually invoked in prod/dev.
  def regenerate reference
    set reference, reference.decorate.send(:generate_formatted), :formatted_cache
    set reference, reference.decorate.send(:generate_inline_citation), :inline_citation_cache
  end
  alias_method :populate, :regenerate

  # `#invalidate_all` and `#regenerate_all` are used in migrations and Rake tasks.
  def invalidate_all
    puts "Invalidating all reference caches...".yellow

    Reference.update_all formatted_cache: nil, inline_citation_cache: nil

    puts "Invalidating all reference caches done.".green
  end

  def regenerate_all
    puts <<-MESSAGE.squish.yellow
      Regenerating all reference caches, this will take MANY minutes, depending
      on how many caches already are up-to-date.
    MESSAGE

    Progress.new_init show_progress: true, total_count: Reference.count, show_errors: true
    Reference.find_each do |reference|
      Progress.tally_and_show_progress 100
      regenerate reference
    end
    Progress.show_results

    puts "Regenerating all reference caches done.".green
  end
end
