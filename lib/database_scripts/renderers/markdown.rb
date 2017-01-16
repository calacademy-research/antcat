module DatabaseScripts::Renderers::Markdown
  def markdown text
    AntcatMarkdown.render text
  end

  def markdown_taxon_link taxon
    "%taxon#{taxon.id}"
  end

  def markdown_reference_link reference
    "%reference#{reference.id}"
  end
end
