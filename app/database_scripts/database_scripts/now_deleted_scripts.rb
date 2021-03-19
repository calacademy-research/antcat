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
            title: 'Now deleted script: SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet ',
            ok?: !Species.joins(:name).joins(:genus).
                    joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
                    where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name").exists?
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
