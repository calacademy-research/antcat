# frozen_string_literal: true

module DatabaseScripts
  class NowDeletedScripts < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def results
      disagreeing_name_parts
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
                    where(<<~SQL.squish).exists?
                      SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
                      SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
                    SQL
          },
          {
            title: 'Now deleted script: TaxaWithNonModernCapitalization',
            ok?: !Taxon.joins(:name).where("name NOT LIKE '%(%' AND BINARY SUBSTRING(name, 2) != LOWER(SUBSTRING(name, 2))").exists?
          }
        ]
      end
  end
end

__END__

section: regression-test
category: Everything
tags: []

description: >
  Incomplete (by design) list of database scripts that have been deleted. This can be ignored.

related_scripts:
  - GrabBagChecks
  - NowDeletedScripts
