module DatabaseScripts
  class NonFossilTaxaWithFossilProtonyms < DatabaseScript
    def results
      Taxon.where(fossil: false).joins(:protonym).where(protonyms: { fossil: true }).includes(:protonym)
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

description: >
  This is not necessarily incorrect.

tags: [new!]
topic_areas: [protonyms]