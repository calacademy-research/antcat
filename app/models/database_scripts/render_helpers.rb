# frozen_string_literal: true

module DatabaseScripts
  module RenderHelpers
    def as_table
      # TODO: Fix hack by passing `results_for_render` in `AsTable#rows`, or evaluate lazily.
      results_for_render = cached_results unless paginate?

      renderer = DatabaseScripts::Renderers::AsTable.new(results_for_render)
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
      "{#{Taxt::TAX_TAG} #{taxon_or_id.try(:id) || taxon_or_id}}"
    end

    def reference_link reference
      link_to(reference.key_with_suffixed_year, reference_path(reference))
    end

    def protonym_link protonym
      protonym.decorate.link_to_protonym
    end

    def protonym_link_with_terminal_taxa protonym
      terminal_taxa_links = CatalogFormatter.link_to_taxa(protonym.terminal_taxa).presence || 'no terminal taxon'
      protonym.decorate.link_to_protonym << "<br>".html_safe << terminal_taxa_links
    end

    def protonym_links protonyms
      protonyms.map { |protonym| protonym.decorate.link_to_protonym }.join('<br>')
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
