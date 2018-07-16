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
        t.header :taxon_that_will_be_deleted, :status, :because, :any_what_links_here?

        t.rows(all_taxa) do |taxon|
          [
            "%taxon#{taxon.id} (##{taxon.id})",
            taxon.status,
            because(taxon),
            what_link_here_thing(taxon)
          ]
        end
      end
    end

    private

      def all_taxa
        all_ids = results.map do |group| group.grouped_ids.split(",") end.flatten
        Taxon.where(id: all_ids, status: "unavailable uncategorized")
      end

      def because taxon
        taxa = Taxon.where(name_cache: taxon.name_cache).where.not(id: taxon.id)

        list = "<ul class='no-bullet'>"
        list << taxa.map do |t|
          "<li>%taxon#{t.id} (##{t.id}, #{t.status})</li>"
        end.join
        list << "</ul>"
        list
      end

      def what_link_here_thing taxon
        return "" unless Taxa::WhatLinksHere[taxon, predicate: true]

        "<a href='/catalog/#{taxon.id}/what_links_here'>yes, show</a>".html_safe
      end
  end
end

__END__
description: >
  List of taxa that will be deleted by script. See %github235.


  Related scripts:
  [Taxa with the same name object](/database_scripts/taxa_with_the_same_name_object)
  and
  [Taxa with the same name cache value](/database_scripts/taxa_with_the_same_name_cache_value).

tags: [regression-test]
topic_areas: [catalog]
