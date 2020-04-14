# frozen_string_literal: true

module DatabaseScripts
  module RenderHelpers
    def as_table
      renderer = DatabaseScripts::Renderers::AsTable.new(cached_results)
      yield renderer
      renderer.render
    end

    def as_taxon_table
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.rank,
            taxon.status
          ]
        end
      end
    end

    def as_protonym_table
      as_table do |t|
        t.header 'ID', 'Protonym'
        t.rows do |protonym|
          [
            protonym.id,
            protonym.decorate.link_to_protonym
          ]
        end
      end
    end

    def as_reference_table
      list = +""
      cached_results.each do |reference|
        list << "* #{reference_link(reference)}\n"
      end
      Markdowns::Render[list, sanitize_content: false]
    end

    def taxa_list taxa
      taxa.map(&:link_to_taxon).join('<br>')
    end

    # NOTE: The reason we're using markdown here is to take advantage of performance tweaks
    # that had already been made for rendering "taxts" in the catalog.
    def taxon_link taxon_or_id
      return "" unless taxon_or_id
      "%taxon#{taxon_or_id.try(:id) || taxon_or_id}"
    end

    def reference_link reference
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
