module DatabaseScripts
  class FossilProtonymsWithNonFossilTaxa < DatabaseScript
    def results
      Protonym.where(fossil: true).joins(:taxa).where(taxa: { fossil: false }).includes(:taxa)
    end

    def render
      as_table do |t|
        t.header :protonym, :taxa
        t.rows do |protonym|
          [
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym.taxa.map { |taxon| taxon.decorate.link_to_taxon }.join('<br>')
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
