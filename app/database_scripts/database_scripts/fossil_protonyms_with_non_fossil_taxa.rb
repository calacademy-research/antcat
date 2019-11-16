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
            protonym.taxa.map(&:link_to_taxon).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

title: Fossil protonyms with non-fossil taxa
description: >
  This is not necessarily incorrect.

tags: []
topic_areas: [protonyms]
related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
