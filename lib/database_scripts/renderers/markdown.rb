module DatabaseScripts::Renderers::Markdown
  def markdown text
    AntcatMarkdown.render text
  end

  def markdown_taxon_link taxon
    "%taxon#{taxon.id}"
  end
end
