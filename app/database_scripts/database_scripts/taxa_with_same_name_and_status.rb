module DatabaseScripts
  class TaxaWithSameNameAndStatus < DatabaseScript
    def results
      Taxon.find_by_sql(<<-SQL)
        SELECT name_cache,
          GROUP_CONCAT(id SEPARATOR ',') AS grouped_ids,
          GROUP_CONCAT(status SEPARATOR ',') AS grouped_statuses
        FROM taxa
        GROUP BY name_cache, status
        HAVING COUNT(*) > 1
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
topic_areas: [catalog]
