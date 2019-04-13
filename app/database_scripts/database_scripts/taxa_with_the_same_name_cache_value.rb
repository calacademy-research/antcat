module DatabaseScripts
  class TaxaWithTheSameNameCacheValue < DatabaseScript
    def results
      Taxon.find_by_sql(<<-SQL)
        SELECT name_cache,
          GROUP_CONCAT(DISTINCT id SEPARATOR ',') AS grouped_ids
        FROM taxa
        GROUP BY name_cache
        HAVING COUNT(*) > 1
      SQL
    end

    def render
      as_table do |t|
        t.header :name_cache, :taxa, :count

        t.rows do |taxon|
          ids = taxon.grouped_ids.split(",")
          [taxon.name_cache, link_taxa_ids(ids), ids.count]
        end
      end
    end

    private

      def link_taxa_ids ids
        list = "<ul class='no-bullet'>"
        list << ids.map { |id| "<li>%taxon#{id} (##{id}) - #{Taxon.find(id).status}</li>" }.join
        list << "</ul>"
      end
  end
end

__END__
description: >
  See %github182. The output of this script is very similar to
  [Taxa with the same name object](/database_scripts/taxa_with_the_same_name_object);
  open both and sort by count to see the difference.

tags: [list]
topic_areas: [names]
