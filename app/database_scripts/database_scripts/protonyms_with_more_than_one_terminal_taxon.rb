# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneTerminalTaxon < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonym.all_statuses_same?(protonym.taxa) &&
        (
          Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa) ||
          Protonym.taxa_genus_and_subgenus_pair?(protonym.taxa)
        )
    end

    def results
      Protonym.joins(:taxa).group(:protonym_id).having(<<~SQL, Status::DISPLAY_HISTORY_ITEMS_VIA_PROTONYM_STATUSES)
        COUNT(CASE WHEN status IN (?) THEN status ELSE NULL END) > 1
      SQL
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa', 'Looks like a false positive?'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
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

section: main
category: Catalog
tags: [new!]

issue_description:

description: >

related_scripts:
  - ProtonymsWithoutATerminalTaxon
  - ProtonymsWithMoreThanOneTerminalTaxon
