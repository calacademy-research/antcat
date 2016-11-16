module DatabaseScripts::Renderers::AsTable
  def as_table &block
    @rendered = ""
    block.call
    markdown @rendered
  end

  def header *items
    string = "|"
    items.each do |item|
      string << " #{item.to_s.humanize} |"
    end
    string << "\n"

    string << "|" << (" --- |" * items.size) << "\n"

    @rendered << string
  end

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
    fields.each do |item|
      string << " #{item} |"
    end
    @rendered << string << "\n"
  end
end
