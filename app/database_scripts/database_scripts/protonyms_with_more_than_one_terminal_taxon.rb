# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneTerminalTaxon < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonyms.all_statuses_same?(protonym.taxa) &&
        (
          Protonyms.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa) ||
          Protonyms.taxa_genus_and_subgenus_pair?(protonym.taxa)
        )
    end

    def empty_status
      DatabaseScripts::EmptyStatus::FALSE_POSITIVES
    end

    def results
      Protonym.joins(:taxa).group(:protonym_id).having(<<~SQL, Status::TERMINAL_STATUSES)
        COUNT(CASE WHEN status IN (?) THEN status ELSE NULL END) > 1
      SQL
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa', 'Looks like a false positive?'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description:

description: >

related_scripts:
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithoutATerminalTaxon
  - ProtonymsWithMoreThanOneTerminalTaxon
