module DatabaseScripts
  class TaxaWithTypeTaxtAndATypeTaxon < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).where.not(type_taxon_id: nil).includes(:type_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxon, :type_taxon_status, :type_taxt, :tt_now, :tt_now_status, :different?, :misc_notes
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
            ('Yes' if type_taxon_now_different),
            misc_notes(type_taxon)
          ]
        end
      end
    end

    private

      def misc_notes type_taxon
        if type_taxon.nomen_nudum?
          'TT is a <i>Nomen nudum</i>'
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

related_scripts:
  - TaxaWithTypeTaxt
  - TaxaWithTypeTaxtAndATypeTaxon
