# frozen_string_literal: true

module DatabaseScripts
  class GrabBagChecks < DatabaseScript
    def results
      [
        all_infrasubspecies_are_invalid,
        all_subgenera_have_names_with_parentheses,
        all_protonyms_have_taxa_with_compatible_ranks,
        original_combination_ranks,
        genus_protonym_names,
        taxa_cleaned_name_check,
        name_count_checks,
        name_caches_sync
      ]
    end

    def render
      as_table do |t|
        t.header 'Check', 'Ok?'
        t.rows do |check|
          [
            check[:title],
            check[:ok?]
          ]
        end
      end
    end

    private

      def all_infrasubspecies_are_invalid
        {
          title: 'All infrasubspecies are invalid',
          ok?: !Infrasubspecies.where(status: Status::VALID).exists?
        }
      end

      def all_subgenera_have_names_with_parentheses
        {
          title: 'All subgenera have names with parentheses',
          ok?: Subgenus.joins(:name).where('names.name LIKE ?', '%(%').count == Subgenus.count
        }
      end

      def all_protonyms_have_taxa_with_compatible_ranks
        {
          title: 'All protonyms have taxa with compatible ranks',
          ok?: !Taxon.group(:protonym_id).having(<<~SQL.squish, Rank::ABOVE_SPECIES).exists?
            COUNT(DISTINCT CASE WHEN type IN (?) THEN 'higher' ELSE 'lower' END) > 1
          SQL
        }
      end

      def original_combination_ranks
        {
          title: "All 'taxa.original_combination' are of correct ranks",
          ok?: !Taxon.where(original_combination: true).where.not(type: Rank::CAN_BE_A_COMBINATION_TYPES).exists?
        }
      end

      def genus_protonym_names
        {
          title: "All genus names are the same as their protonym's names",
          ok?: !Genus.joins(:name, protonym: :name).where('names.name != names_protonyms.name').exists?
        }
      end

      def taxa_cleaned_name_check
        {
          title: "All 'names.cleaned_name' of non-subgenus taxa match its 'names.name'",
          ok?: !Taxon.where.not(type: Rank::SUBGENUS).joins(:name).where("names.cleaned_name != names.name").exists?
        }
      end

      def name_count_checks
        orphaned_names = Name.left_outer_joins(:taxa, :protonyms).where("protonyms.id IS NULL AND taxa.id IS NULL")

        ok =
          !Protonym.where(name_id: Taxon.distinct.select(:name_id)).exists? &&
          !Taxon.where(name_id: Protonym.distinct.select(:name_id)).exists? &&
          (Name.count == Taxon.count + Protonym.count) &&
          !orphaned_names.exists?

        {
          title: 'Name count checks',
          ok?: ok
        }
      end

      def name_caches_sync
        {
          title: "All 'taxa.name_cache' fields are in sync with its 'names.name' fields",
          ok?: !Taxon.joins(:name).where("names.name != taxa.name_cache").exists?
        }
      end
  end
end

__END__

section: regression-test
category: Everything
tags: []

description: >
  Random checks. This can be ignored.

related_scripts:
  - GrabBagChecks
  - NowDeletedScripts
