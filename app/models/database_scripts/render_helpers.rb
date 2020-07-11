# frozen_string_literal: true

module DatabaseScripts
  module RenderHelpers
    def as_table
      renderer = DatabaseScripts::Renderers::AsTable.new(cached_results)
      yield renderer
      renderer.render
    end

    def taxon_links taxa
      taxa.map { |taxon| CatalogFormatter.link_to_taxon(taxon) }.join('<br>')
    end

    def taxon_links_with_author_citations taxa
      taxa.map { |taxon| CatalogFormatter.link_to_taxon(taxon) + " #{taxon.author_citation}" }.join('<br>')
    end

    # NOTE: The reason we're using markdown here is to take advantage of performance optimizations
    # that have been made for rendering "taxts" in the catalog.
    def taxon_link taxon_or_id
      return "" unless taxon_or_id
      "{tax #{taxon_or_id.try(:id) || taxon_or_id}}"
    end

    def bold_warning string
      %(<span class="bold-warning">#{string}</span>)
    end

    def bold_notice string
      %(<span class="bold-notice">#{string}</span>)
    end

    def gray_notice string
      %(<span class="gray-notice">#{string}</span>)
    end

    def purple_notice string
      %(<span class="purple-notice">#{string}</span>)
    end
  end
end
