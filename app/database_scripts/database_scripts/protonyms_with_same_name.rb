module DatabaseScripts
  class ProtonymsWithSameName < DatabaseScript
    def results
      same_name_name = Protonym.joins(:name).group('names.name').having('COUNT(protonyms.id) > 1')

      Protonym.joins(:name).where(names: { name: same_name_name.select('names.name') }).
        order('names.name').
        includes(:name, authorship: [:reference])
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Statuses of taxa', 'Any unresolved homonyms?'
        t.rows do |protonym|
          taxa_statuses = protonym.taxa.pluck(:status)

          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            taxa_statuses.present? ? taxa_statuses.join(', ').truncate(50) : bold_warning('Orphaned protonym'),
            protonym.taxa.where(unresolved_homonym: true).exists? ? 'Yes' : ''
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: [list, slow]

description: >
  Protonym records with the same name (`names.name`).


  Many of these are OK. Most that are not OK will appear in various other database scripts.


  It's still a little bit fuzzy to me how to identify true duplicates by script. Two different protonym records with the same name
  are probably duplicates if both taxa linked to the protonym are valid.
  If one the linked taxa has the status `homonym`, or `unresolved_homonym` set to true (this is
  the unresolved junior homonym checkbox in the taxon form), then the protonyms are likely not true duplicates and should not be merged.


  I think it's best to focus on other protonym scripts first.


  **How to fix**


  * Orphaned protonyms can be deleted or ignored

  * If the authorship is identical: change protonym of one and delete the now orphaned protonym

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart
