module DatabaseScripts
  class GrabBagChecks < DatabaseScript
    def results
      [
        all_subgenera_have_names_with_parentheses,
        name_count_checks,
        name_caches_sync
      ]
    end

    def render
      as_table do |t|
        t.header :check, :ok?
        t.rows do |check|
          [
            check[:title],
            check[:ok?]
          ]
        end
      end
    end

    private

      def all_subgenera_have_names_with_parentheses
        {
          title: 'All subgenera have names with parentheses',
          ok?: Subgenus.joins(:name).where('names.name LIKE ?', '%(%').count == Subgenus.count
        }
      end

      def name_count_checks
        ok =
          !Protonym.where(name_id: Taxon.distinct.select(:name_id)).exists? &&
          !Taxon.where(name_id: Protonym.distinct.select(:name_id)).exists? &&
          (Name.count == Taxon.count + Protonym.count) &&
          !Name.orphaned.exists?

        {
          title: 'Name count checks',
          ok?: ok
        }
      end

      def name_caches_sync
        {
          title: 'All taxa.name_cache fields are in sync with its names.name fields',
          ok?: !Taxon.joins(:name).where("names.name != taxa.name_cache").exists?
        }
      end
  end
end

__END__

category: Catalog
tags: [new!, list]

description: >
  Random checks. This can be ignored.
