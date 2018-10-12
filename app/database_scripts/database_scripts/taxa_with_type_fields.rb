module DatabaseScripts
  class TaxaWithTypeFields < DatabaseScript
    def results
      taxa_with_type_specimen_repositories_or_codes
    end

    def render
      as_table do |t|
        t.header :taxon, :status,
          :verbatim_type_locality, :type_specimen_repository,
          :TSR_automatically_replaceable?, :type_specimen_code,
          :primary_type_information, :secondary_type_information, :type_notes

        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.verbatim_type_locality,
            taxon.type_specimen_repository,
            replace_with_abbreviation?(taxon.type_specimen_repository) ? 'Yes' : 'No',
            Types::FormatTypeField[taxon.type_specimen_code],
            Types::FormatTypeField[taxon.primary_type_information],
            taxon.secondary_type_information,
            taxon.type_notes
          ]
        end
      end
    end

    private

      # TODO `Taxon.where.not` is not used.
      def taxa_with_type_specimen_repositories_or_codes
        ids = Taxon.where.not(verbatim_type_locality: [nil, '']).pluck(:id) +
          Taxon.where.not(type_specimen_code: [nil, '']).pluck(:id) +
          Taxon.where.not(type_specimen_repository: [nil, '']).pluck(:id)
        Taxon.where.not(primary_type_information: [nil, '']).pluck(:id)
        Taxon.where.not(secondary_type_information: [nil, '']).pluck(:id)
        Taxon.where.not(type_notes: [nil, '']).pluck(:id)
        Taxon.where(id: ids.uniq)
      end

      def replace_with_abbreviation? repo
        return false if repo.blank?
        return false unless repo.count('(') == 1
        return false unless repo.count(')') == 1

        repo =~ institutions_regex
      end

      def institutions_regex
        @institutions_regex ||= begin
          abbreviation = Institution.pluck(:abbreviation)
          /\((#{abbreviation.join('|')})\)/
        end
      end
  end
end

__END__
description: >
  Script contains:


  * The three old type fields that are to be removed: `verbatim_type_locality`, `type_specimen_code` and `type_specimen_repository`.

  * And the three new fields: `primary_type_information`, `secondary_type_information` and `type_notes`.



  "Yes" in the "Tsr automatically replaceable?" column means that the data migration
  script could find a single institution abbreviation in the `type_specimen_repository`
  field and replaced it with the abbreviation only before concatenating the fields. "No"
  means the field was copied as is.


  See [Edit institutions](/institutions) for all
  a list of all institutions.

tags: [list, slow]
topic_areas: [types]
