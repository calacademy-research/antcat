module DatabaseScripts
  class TaxaWithUncommonTypeTaxts < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).
        where.not(type_taxt: [Protonym::BY_MONOTYPY, Protonym::BY_ORIGINAL_DESIGNATION]).
        where("type_taxt NOT REGEXP ?", Protonym::BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF_MYSQL)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxt, :default_expansion
        t.rows do |taxon|
          type_taxt = taxon.type_taxt

          [
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[type_taxt],
            expansion(taxon)
          ]
        end
      end
    end

    private

      def expansion taxon
        TypeTaxonExpander.new(taxon).expansion(ignore_can_expand: true)
      end
  end
end

__END__

title: Taxa with uncommon <code>type_taxt</code>s
category: Catalog
tags: []

issue_description: This taxon has an "uncommon" `type_taxt` (see script for more info).

description: >
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
