# frozen_string_literal: true

module DatabaseScripts
  class SpeciesGroupTaxaNotSpelledForTheirGenusGender < DatabaseScript
    def self.record_in_results? taxon
      return false unless taxon.is_a?(SpeciesGroupTaxon)
      new.results.where(id: taxon.id).exists?
    end

    def results
      SpeciesGroupTaxon.
        where.not(status: Status::UNAVAILABLE_MISSPELLING).
        preload(:protonym, genus: :name).
        joins(:name, :protonym).
        joins('INNER JOIN taxa genera ON genera.id = taxa.genus_id').
        joins('INNER JOIN names genus_names ON genus_names.id = genera.name_id').
        where(protonyms: { gender_agreement_type: Protonym::CHANGEABLE_GENDER_AGREEMENT_TYPES }).
        # Spellings kept on purpose, and disputed or unsettled readings, are not errors (review of #1607).
        where('protonyms.spelling_basis IS NULL OR protonyms.spelling_basis NOT IN (?)',
          Protonym::SPELLING_KEPT_AGAINST_AGREEMENT_BASES).
        where('protonyms.interpretation_status IS NULL OR protonyms.interpretation_status NOT IN (?)',
          Protonym::SCRIPTED_SPELLING_CHANGE_BLOCKED_STATUSES).
        where(<<~SQL.squish)
          names.epithet <> CASE genus_names.gender
            WHEN 'masculine' THEN protonyms.masculine_epithet
            WHEN 'feminine' THEN protonyms.feminine_epithet
            WHEN 'neuter' THEN protonyms.neuter_epithet
          END
        SQL
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Genus', 'Genus gender', 'Spelling for that gender', 'Protonym'
        t.rows do |taxon|
          genus = taxon.genus
          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(genus),
            genus.name.gender,
            taxon.protonym.epithet_for_gender(genus.name.gender),
            protonym_link(taxon.protonym)
          ]
        end
      end
    end
  end
end

__END__

title: Species-group taxa not spelled for their genus gender

section: research
tags: [taxa, protonyms, names, new!]

description: >
  The protonym is an adjective or participle and records its spelling in each genus gender, but this taxon's
  epithet is not the spelling for the gender of its genus. Either the taxon's name or one of the protonym's
  spellings is wrong.


  Taxa with no recorded spellings, or in genera with no gender, are not checked. Unavailable misspellings are
  excluded.

issue_description: This name is not spelled for the gender of its genus.

related_scripts:
  - SpeciesGroupTaxaNotSpelledForTheirGenusGender
