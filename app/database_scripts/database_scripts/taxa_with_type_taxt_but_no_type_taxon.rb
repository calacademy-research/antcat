module DatabaseScripts
  class TaxaWithTypeTaxtButNoTypeTaxon < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).where(type_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxt
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxon.type_taxt]
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with <code>type_taxt</code> but no type taxon
category: Inline taxt
tags: [new!]

description: >
  Table/column: `taxa.type_taxt` (called "Notes" in the "Type" section of the taxon form)


  The `type_taxt` is not shown in the catalog if there is no type taxon, but we want to fix these anyways so that we can add validation for it.


  **How to fix:** Set a type taxon if it's missing, or clear the "Notes" field in the "Type" section.

related_scripts:
  - TaxaWithTypeTaxt
  - TaxaWithTypeTaxtAndATypeTaxon
  - TaxaWithTypeTaxtButNoTypeTaxon
