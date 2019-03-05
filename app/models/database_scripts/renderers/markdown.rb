module DatabaseScripts::Renderers::Markdown
  def markdown content
    Markdowns::Render[content, sanitize_content: false]
  end

  def markdown_taxon_link taxon_or_id
    return "" unless taxon_or_id
    "%taxon#{taxon_or_id.try(:id) || taxon_or_id}"
  end

  def markdown_reference_link reference
    "%reference#{reference.id}"
  end
end
