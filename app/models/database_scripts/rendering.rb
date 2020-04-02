# frozen_string_literal: true

module DatabaseScripts
  module Rendering
    include DatabaseScripts::Renderers::AsTable

    # Tries to be smart whenever not overridden in the scripts.
    def render
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
        return FOUND_NO_DATABASE_ISSUES if cached_results.blank?
        "Error: cannot implicitly render results."
      else
        "Error: cannot implicitly render results."
      end
    end

    def as_taxon_table
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
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

    def as_reference_list
      list = +""
      cached_results.each do |reference|
        list << "* #{markdown_reference_link(reference)}\n"
      end
      markdown list
    end
  end
end
