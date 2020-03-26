module DatabaseScripts
  module ViewHelpers
    def taxa_list taxa
      taxa.map(&:link_to_taxon).join('<br>')
    end

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

    def bold_warning string
      %(<span class="bold-warning">#{string}</span>)
    end

    # :nocov:
    def origin_warning taxon
      return '' unless taxon.origin
      '&nbsp;' + bold_warning(taxon.origin)
    end
    # :nocov:
  end
end
