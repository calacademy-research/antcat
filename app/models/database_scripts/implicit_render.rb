# frozen_string_literal: true

module DatabaseScripts
  module ImplicitRender
    # Implicitly render based on result type, unless overridden in script.
    def render
      implicit_render
    end

    private

      def implicit_render
        case cached_results
        when ActiveRecord::Relation
          case cached_results.table.name # `#base_class` or `#klass` doesn't work for some reason.
          when "taxa" then as_taxon_table
          when "protonyms" then as_protonym_table
          when "references" then as_reference_list
          else "Error: cannot implicitly render ActiveRecord::Relation."
          end
        when Array
          return as_taxon_table if cached_results.first.is_a?(Taxon)
          return DatabaseScripts::Renderers::AsTable::FOUND_NO_DATABASE_ISSUES if cached_results.blank?
          "Error: cannot implicitly render results."
        else
          "Error: cannot implicitly render results."
        end
      end
  end
end
