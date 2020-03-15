module DatabaseScripts
  class MoveTypeTaxonToProtonymByScript < DatabaseScript
    def results
      Taxon.where.not(type_taxon: nil).includes(:type_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Type taxon', 'type_taxt', 'Protonym'
        t.rows do |taxon|
          type_taxon = taxon. type_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(type_taxon),
            taxon.type_taxt,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

category: Script (pending)
tags: []

description: >
  **Todo:**


  * Clear red "No"s in %dbscript:ProtonymsWithTaxaWithMoreThanOneTypeTaxon

  * Clear %dbscript:TaxaWithUncommonTypeTaxts
