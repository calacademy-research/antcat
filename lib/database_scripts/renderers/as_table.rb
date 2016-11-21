module DatabaseScripts::Renderers::AsTable
  def as_table &block
    @rendered = ""
    block.call
    markdown @rendered
  end

  def header *items
    # Say `items` are the array [:taxon, :status], then this part looks
    # like this: "| Taxon | Status |".
    string = "|"
    items.each { |item| string << " #{item.to_s.humanize} |" }
    string << "\n"

    # Part of the markdown table syntax. Looks like: "| --- | --- |".
    string << "|" << (" --- |" * items.size) << "\n"

    @rendered << string
  end

  # Gets the results from `#results` unless specified. This is the most common
  # use-case (single results list); see ´scripts/valid_taxa_with_non_valid_parents.rb`
  # for an example with multiple rows and explicit `results`s.
  def rows results = nil, &block
    results ||= cached_results

    if results.blank?
      @rendered << "| Found no database issues |" << "\n"
      return
    end

    results.each do |object|
      row object, *block.call(object)
    end
  end

  def row result, *fields
    string = "|"
    fields.each { |item| string << " #{item} |" }
    @rendered << string << "\n"
  end
end
