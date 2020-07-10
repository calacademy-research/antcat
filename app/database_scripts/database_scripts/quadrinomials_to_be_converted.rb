# frozen_string_literal: true

# TODO: [grep:quadrinomials].
module DatabaseScripts
  class QuadrinomialsToBeConverted < DatabaseScript
    def results
      Subspecies.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Convertable?', 'Target subspecies',
          'Status', 'Target subspecies validation issues', 'Quick-add button', 'Quick-add attributes'

        t.rows do |taxon|
          name_string = taxon.name_cache
          target_subspecies_name_string = name_string.split[0..2].join(' ')
          target_subspecies_candiates = Subspecies.where(name_cache: target_subspecies_name_string)

          convertable = target_subspecies_candiates.count == 1
          target_subspecies = target_subspecies_candiates.first

          quick_adder = QuickAdd::FromExistingQuadrinomial.new(taxon)

          [
            taxon_link(taxon),
            taxon.status,
            ('Yes' if convertable),
            (CatalogFormatter.link_to_taxon(target_subspecies) if convertable),
            (target_subspecies.status if convertable),
            (format_failed_soft_validations(target_subspecies) if convertable && target_subspecies.soft_validations.failed?),
            (new_taxon_link(quick_adder) unless convertable),
            (quick_adder.synopsis unless convertable)
          ]
        end
      end
    end

    private

      def format_failed_soft_validations target_subspecies
        target_subspecies.soft_validations.failed.reject do |validation|
          validation.database_script.is_a?(DatabaseScripts::NonValidTaxaWithACurrentTaxonThatIsNotValid)
        end.map(&:issue_description).join('<br><br>')
      end

      def new_taxon_link quick_adder
        label = "Add #{quick_adder.rank}"
        link_to label, new_taxa_path(quick_adder.taxon_form_params), class: "btn-tiny btn-normal"
      end
  end
end

__END__

section: pa-action-required
category: Catalog
tags: [slow, has-quick-fix, high-priority]

description: >
  Records with a "Yes" in the "Convertable?" column can be converted by script. It's not possible to manually fix them.


  **Todo:**


  * Create missing subspecies - the "quick-add" button opens the taxon form with prefilled values, which can be adjusted before saving.


  Some of species may be missing due to them being misspelled, or just not
  found in case the quadronomial is misspelled.


  <span class='bold-notice'>[similar to subspecies epithet]</span> and
  <span class='bold-warning'>[similar to infrasubspecies epithet]</span> are used to highlight epithets of existing subspecies
  starting with the same first three letters.


  Issues: %github714, %github819, [AC #41](/issues/41)

related_scripts:
  - QuadrinomialsToBeConverted
