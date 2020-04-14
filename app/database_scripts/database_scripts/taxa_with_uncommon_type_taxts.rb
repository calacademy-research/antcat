# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithUncommonTypeTaxts < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).
        where.not(type_taxt: [Protonym::BY_MONOTYPY, Protonym::BY_ORIGINAL_DESIGNATION]).
        where("type_taxt NOT REGEXP ?", Protonym::BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF_MYSQL)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'AntWiki', 'Type taxon', 'TT status', 'type_taxt', 'Default expansion'
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxt = taxon.type_taxt

          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.decorate.link_to_antwiki,
            markdown_taxon_link(type_taxon),
            type_taxon.status,
            Detax[type_taxt],
            expansion(taxon),
            clear_type_taxt_link(taxon)
          ]
        end
      end
    end

    private

      def expansion taxon
        TypeTaxonExpander.new(taxon).expansion(ignore_can_expand: true)
      end

      def clear_type_taxt_link taxon
        link_to 'Clear!', clear_type_taxt_quick_and_dirty_fix_path(taxon_id: taxon.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: Taxa with uncommon <code>type_taxt</code>s

section: pa-action-required
category: Catalog
tags: [has-quick-fix]

issue_description: This taxon has an "uncommon" `type_taxt` (see script for more info).

description: >
  Experimental: Use the "Clear!" button to quickly remove everything except the "common parts".
  Refresh the page to get rid cleaned items.
  Some items may have to be adjusted for punctuation afterwards. The activity feed will include the old and new
  `type_taxt`, so just try it out and see what happens :)


  The goal of this script is make data more concistent and more relational (database friendly). This is the first step (basic cleanup).
  The long-term plan is to move the type taxon to the protonym.


  The default expansion does not fully cover all cases, for example homonyms are expanded to just

  > (homonym replaced by Camponotus repens)


  because I don't know how and if we can automatically expand it to

  > (junior secondary homonym in Camponotus; replacement name: Camponotus repens)


  *Nomen nudum* cases are probably also not 100% supported because I just realized that only `unavailable` taxa can be *nomina nuda*. See {tax 429052} for an example.


  Special cases can be discussed.


  **How to fix:**

  Only "common" `type_taxt`s are expanded. Edit the `type_taxt` to be a common one.


  Example:


  * Taxon: *Polyrhachis (Florencea)*

  * `type_taxon`: *Polyrhachis kirkae*

  * `type_taxt`: `(junior synonym of Polyrhachis nigriceps), by original designation.`

  Change the `type_taxt` to `, by original designation.` and the expansion will automatically be inserted.


  **Common `type_taxt`s:**


  * `, by monotypy.`

  * `, by original designation.`

  * `, by subsequent designation of {ref <ID>}: <page number>.`

related_scripts:
  - TaxaWithTypeTaxa
  - TaxaWithTypeTaxt
  - TaxaWithUncommonTypeTaxts
