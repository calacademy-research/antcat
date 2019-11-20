module DatabaseScripts
  class FossilTaxaWithNonFossilProtonyms < DatabaseScript
    def results
      Taxon.where(fossil: true).joins(:protonym).where(protonyms: { fossil: false }).includes(:protonym)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :protonym
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            protonym_link(taxon.protonym)
          ]
        end
      end
    end
  end
end

__END__

title: Fossil taxa with non-fossil protonyms
category: Protonyms

description: >
  This is not necessarily incorrect.

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
