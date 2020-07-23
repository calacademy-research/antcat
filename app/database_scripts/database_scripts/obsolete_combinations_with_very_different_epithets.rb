# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithVeryDifferentEpithets < DatabaseScript
    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAMES).obsolete_combinations.joins(:name, current_taxon: :name).
        where(current_taxons_taxa: { type: Rank::SPECIES_GROUP_NAMES }).
        where("SUBSTR(names_taxa.epithet, 1, 3) != SUBSTR(names.epithet, 1, 3)").
        includes(:name, current_taxon: :name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'current_taxon',
          'current_taxon status', 'Taxon epithet', 'current_taxon epithet',
          'Quick-fix links'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.type,
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status,
            taxon.name.epithet,
            current_taxon.name.epithet,

            quick_fix_links(taxon)
          ]
        end
      end
    end

    private

      def quick_fix_links taxon
        taxon.protonym.taxa.where.not(id: taxon.id).map do |other_taxon|
          rank_notice = if taxon.rank == other_taxon.rank
                          bold_notice("same rank!")
                        else
                          bold_warning("NOT same rank!")
                        end
          "#{bold_warning('See notice in description')} #{CatalogFormatter.link_to_taxon(other_taxon)} #{other_taxon.status} #{quick_fix_link(taxon, other_taxon)} #{rank_notice}<br><br>".html_safe
        end.join
      end

      def quick_fix_link taxon, other_taxon
        url = update_current_taxon_id_quick_and_dirty_fix_path(taxon_id: taxon.id, new_current_taxon_id: other_taxon.id)
        is_same_as_current_current_taxon = other_taxon.current_taxon == taxon.current_taxon
        link_css_color = is_same_as_current_current_taxon ? 'btn-normal btn-tiny' : 'btn-warning btn-tiny'
        link_to 'Set as CT!', url, method: :post, remote: true, class: link_css_color
      end
  end
end

__END__

section: regression-test
category: Catalog
tags: [slow-render, has-quick-fix]

issue_description: This obsolete combination has a very different epithet compared to its `current_taxon`.

description: >
  "Very different" means that the first three letters in the epithet are not the same.


  The suggestions in the **Quick-fix links** columns are all from **Taxon**'s protonym (excluding **Taxon** itself).


  Blue button means that the `current_taxon` of that quick-fix suggestion is the same as **Taxon**'s
  `current_taxon` (which is shown in the **current_taxon** column).


  Red button means that it's not.


  Regarding <span class="bold-warning">See notice in description</span>: the quick-fix button is not very relevant for remaining cases,
  but I left it in place anyways because the help text is still useful.


  Records in this script also often appears in %dbscript:ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
