# frozen_string_literal: true

module DatabaseScripts
  class GrabBagChecks < DatabaseScript
    def results
      [
        all_subgenera_have_names_with_parentheses,
        all_protonyms_have_taxa_with_compatible_ranks,
        name_count_checks,
        name_caches_sync
      ].concat disagreeing_name_parts
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

      def all_subgenera_have_names_with_parentheses
        {
          title: 'All subgenera have names with parentheses',
          ok?: Subgenus.joins(:name).where('names.name LIKE ?', '%(%').count == Subgenus.count
        }
      end

      def all_protonyms_have_taxa_with_compatible_ranks
        {
          title: 'All protonyms have taxa with compatible ranks',
          ok?: !Taxon.group(:protonym_id).having(<<~SQL, Rank::TYPES_ABOVE_SPECIES).exists?
            COUNT(DISTINCT CASE WHEN type IN (?) THEN 'higher' ELSE 'lower' END) > 1
          SQL
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
          title: 'All taxa.name_cache fields are in sync with its names.name fields',
          ok?: !Taxon.joins(:name).where("names.name != taxa.name_cache").exists?
        }
      end

      def disagreeing_name_parts
        [
          {
            title: 'Now deleted script: SpeciesDisagreeingWithGenusRegardingSubfamily ',
            ok?: !Species.joins(:genus).where("genera_taxa.subfamily_id != taxa.subfamily_id").exists?
          },
          {
            title: 'Now deleted script: SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet ',
            ok?: !Species.joins(:name).joins(:genus).
                    joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
                    where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name").exists?
          },
          {
            title: 'Now deleted script: SubspeciesDisagreeingWithSpeciesRegardingGenus ',
            ok?: !Subspecies.joins(:species).where("species_taxa.genus_id != taxa.genus_id").exists?
          },
          {
            title: 'Now deleted script: SubspeciesDisagreeingWithSpeciesRegardingSubfamily ',
            ok?: !Subspecies.joins(:species).where("species_taxa.subfamily_id != taxa.subfamily_id").exists?
          },
          {
            title: 'Now deleted script: SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet ',
            ok?: !Subspecies.joins(:name).joins(:genus).
                    joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
                    where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name").exists?
          },
          {
            title: 'Now deleted script: SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet ',
            ok?: !Subspecies.joins(:name).joins(:species).
                    joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
                    where(<<~SQL).exists?
                      SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
                      SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
                    SQL
          }
        ]
      end
  end
end

__END__

section: list
category: Catalog
tags: []

description: >
  Random checks. This can be ignored.
