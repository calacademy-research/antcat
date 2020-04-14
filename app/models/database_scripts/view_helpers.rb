# frozen_string_literal: true

module DatabaseScripts
  module ViewHelpers
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
