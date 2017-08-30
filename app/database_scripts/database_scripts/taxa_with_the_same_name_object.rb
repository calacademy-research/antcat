# `#render and #link_taxa_ids` are from `taxa_with_the_same_name_cache_value.rb`.

module DatabaseScripts
  class TaxaWithTheSameNameObject < DatabaseScript
    def results
      Taxon.find_by_sql(<<-SQL)
        SELECT name_cache,
          GROUP_CONCAT(DISTINCT id SEPARATOR ',') AS grouped_ids
        FROM taxa
        GROUP BY name_id
        HAVING COUNT(*) > 1
        ORDER BY name_cache
      SQL
    end

    def render
      as_table do
        header :name_cache, :taxa, :count

        rows do |taxon|
          ids = taxon.grouped_ids.split(",")
          [ taxon.name_cache, link_taxa_ids(ids), ids.count ]
        end
      end
    end

    private
      def link_taxa_ids ids
        list = "<ul class='no-bullet'>"
        list << ids.map {|id| "<li>%taxon#{id} (##{id})</li>" }.join
        list << "</ul>"
      end
  end
end

__END__
description: >
  See
  [Taxa with the same name cache value](/database_scripts/taxa_with_the_same_name_cache_value)
  for some notes.

tags: [slow]
topic_areas: [catalog]
