module DatabaseScripts
  class ProtonymsWithSameNameExcludingSubgenusPart < DatabaseScript
    def results
      dups_names = dups.map { |(name, _id)| name }
      dups_ids = dups.map { |(_name, id)| id }

      protonyms.where(id: dups_ids).or(protonyms.where(names: { name: dups_names })).order('names.epithet').
        includes(:name, authorship: :reference)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey
          ]
        end
      end
    end

    private

      def protonyms
        Protonym.joins(:name).where(names: { type: ["SpeciesName", "SubspeciesName"] })
      end

      def dups
        @dups ||= begin
          names_and_ids = protonyms.pluck('names.name', 'protonyms.id')
          names_only = names_and_ids.map { |(name, _id)| name }

          names_and_ids_containing_subgenus = protonyms.where('names.name LIKE ?', '%(%').pluck('names.name', 'protonyms.id')
          stripped_names_and_ids_containing_subgenus = names_and_ids_containing_subgenus.map do |(name, id)|
            [name.gsub(/\(.*?\) ?/, ''), id]
          end

          stripped_names_and_ids_containing_subgenus.select { |(name, _id)| names_only.include?(name) }
        end
      end
  end
end

__END__

category: Catalog
tags: [regression-test, slow]

description: >
  This script checks all species and subspecies protonyms which includes a subgenus part in the name.


  Names are compared without the subgenus part, and any duplicates are listed here.
  Duplicates with different authorships are likely homonyms, which is not an issue.


  Initial order is by epithet.

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart
