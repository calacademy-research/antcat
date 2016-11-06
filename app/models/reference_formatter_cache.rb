class ReferenceFormatterCache
  include Singleton

  def invalidate reference
    return unless reference.formatted_cache?
    unless reference.new_record?
      set reference, nil, :formatted_cache
      set reference, nil, :inline_citation_cache
    end
    reference.nestees.each { |nestee| invalidate nestee }
  end

  def get reference, field = :formatted_cache
    reference.send field # YOLO committed the faster version

    # TODO reinstante if issue occurs, else, remove.
    # This method previosuly caintained this:
    ##################################################################
    # Wrapped in a `#find` call to make sure the reference is reloaded.
    # May only be required to pass tests.
    # TODO investigate removing it, because it adds an additional SQL query.
    # We want this instead: `reference.send field`
    #Reference.find(reference.id).send field
    ##################################################################
  end

  def set reference, value, field = :formatted_cache
    return value if reference.send(field) == value
    reference.update_column field, value
    value
  end

  def invalidate_all
    puts "Invalidating all reference caches, this till take a few minutes."

    references = Reference
    Progress.new_init show_progress: true, total_count: references.count, show_errors: true
    references.find_each do |reference|
      Progress.tally_and_show_progress 100
      invalidate reference
    end
    Progress.show_results
  end

  def regenerate_all
    puts "Regenerating all reference caches, this will take MANY minutes, depending"
    puts "on how many caches already are up-to-date."

    references = Reference.all
    Progress.new_init show_progress: true, total_count: references.count, show_errors: true
    references.each do |reference|
      Progress.tally_and_show_progress 100
      regenerate reference
    end
    Progress.show_results
  end

  def regenerate reference
    set reference, reference.decorate.format!, :formatted_cache
    set reference, reference.decorate.format_inline_citation!, :inline_citation_cache
  end
  alias_method :populate, :regenerate
end
