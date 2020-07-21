# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithCurrentTaxonsThatAreAlsoObsoleteCombinations < DatabaseScript
    def results
      Taxon.obsolete_combinations.
        joins(:current_taxon).
        where(current_taxons_taxa: { status: Status::OBSOLETE_COMBINATION })
    end

    def render
      as_table do |t|
        t.header 'Very obsolete combination (VOC)', 'Less obsolete combination (LOC)',
          'current_taxon of LOC', 'Quick-fix'
        t.rows do |very_obsolete_combination|
          less_obsolete_combination = very_obsolete_combination.current_taxon
          current_taxon = less_obsolete_combination.current_taxon

          [
            taxon_link(very_obsolete_combination),
            taxon_link(less_obsolete_combination),
            taxon_link(current_taxon),
            quick_fix_link(very_obsolete_combination, current_taxon)
          ]
        end
      end
    end

    private

      def quick_fix_link very_obsolete_combination, current_taxon
        unless Status.status_of_current_taxon_allowed?(very_obsolete_combination.status, current_taxon.status)
          return bold_warning("status of current_taxon is not allowed for obsolete combinations!")
        end

        description = quick_fix_description(very_obsolete_combination, current_taxon)

        url = update_current_taxon_id_quick_and_dirty_fix_path(
          taxon_id: very_obsolete_combination.id,
          new_current_taxon_id: current_taxon.id
        )
        link = link_to "Set as CT for VOC!", url, method: :post, remote: true, class: 'btn-normal btn-tiny'

        description + link
      end

      def quick_fix_description very_obsolete_combination, current_taxon
        <<~STRING
          Set #{CatalogFormatter.link_to_taxon(current_taxon)}
          <br>
          as <code>current_taxon</code> of #{CatalogFormatter.link_to_taxon(very_obsolete_combination)}
          <br>
        STRING
      end
  end
end

__END__

title: Obsolete combinations with <code>current_taxon</code>s that are also obsolete combinations

section: regression-test
category: Catalog
tags: [new!, has-quick-fix]

issue_description: This taxon has an obsolete combinations as its `current_taxon`, but it is itself an obsolete combination.

description: >
  This script is the reverse of %dbscript:ObsoleteCombinationsWithObsoleteCombinations

related_scripts:
  - ObsoleteCombinationsWithCurrentTaxonsThatAreAlsoObsoleteCombinations
