# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTaxaWithVeryDifferentEpithets < DatabaseScript
    def results
      Protonym.joins(taxa: :name).
        where(taxa: { type: 'Species' }).
        group('protonyms.id').having("COUNT(DISTINCT SUBSTR(names.epithet, 1, 3)) > 1").distinct.
        includes(:name)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Epithets of taxa', 'Ranks of taxa', 'Statuses of taxa', 'Taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.taxa.joins(:name).pluck(:epithet).join(', '),
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            protonym.taxa.map { |tax| tax.link_to_taxon + origin_warning(tax).html_safe }.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: []

issue_description: The taxa of this protonym have very different epithets.

description: >
  "Very different" means that the first three letters in the epithet are not the same.


  Only species checked.

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
