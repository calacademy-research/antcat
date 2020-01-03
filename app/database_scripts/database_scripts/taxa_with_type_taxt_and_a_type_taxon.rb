module DatabaseScripts
  class TaxaWithTypeTaxtAndATypeTaxon < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).where.not(type_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxon, :type_taxon_status, :type_taxt, :tt_now, :tt_now_status, :different?
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.now
          type_taxon_now_different = type_taxon_now != type_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(type_taxon),
            type_taxon.status,

            Detax[taxon.type_taxt],

            markdown_taxon_link(type_taxon_now),
            type_taxon_now.status,
            ('yes' if type_taxon_now_different)
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with <code>type_taxt</code> and a type taxon
category: Inline taxt
tags: [new!, list, slow]

description: >
  Table/column: `taxa.type_taxt` (called "Notes" in the "Type" section of the taxon form)


  "Different?" indicates that the type taxon is not the same as "type taxon now" (not a real thing, yet).


  Records without a type taxon are excluded (see %dbscript:TaxaWithTypeTaxtButNoTypeTaxon).

related_scripts:
  - TaxaWithTypeTaxt
  - TaxaWithTypeTaxtAndATypeTaxon
  - TaxaWithTypeTaxtButNoTypeTaxon
