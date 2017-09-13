module DatabaseScripts
  class UnavailableUncategorizedTaxaWithSameNamesAtOtherTaxa < DatabaseScript
    def results
      Taxon.find_by_sql(<<-SQL)
        SELECT name_cache,
          GROUP_CONCAT(id SEPARATOR ',') AS grouped_ids,
          GROUP_CONCAT(status SEPARATOR ',') AS grouped_statuses
        FROM taxa
        GROUP BY name_cache
        HAVING COUNT(*) > 1
          AND COUNT(CASE WHEN status = 'unavailable uncategorized' THEN 1 END) >= 1
      SQL
    end

    def render
      as_table do |t|
        t.header :name_cache, :taxa, :count

        t.rows do |taxon|
          ids = taxon.grouped_ids.split(",")
          statuses = taxon.grouped_statuses.split(",")
          taxa = ids.zip statuses

          [ taxon.name_cache, taxa_links_with_status(taxa), ids.count ]
        end
      end
    end

    private
      def taxa_links_with_status taxa
        list = "<ul class='no-bullet'>"
        list << taxa.map do |id, status|
          "<li>%taxon#{id} (##{id}, #{status})</li>"
        end.join
        list << "</ul>"
      end
  end
end

__END__
description: >
  See %github235.


  Related scripts:
  [Taxa with the same name object](/database_scripts/taxa_with_the_same_name_object)
  and
  [Taxa with the same name cache value](/database_scripts/taxa_with_the_same_name_cache_value).

tags: [new!, slow]
topic_areas: [catalog]
