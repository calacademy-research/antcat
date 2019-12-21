module DatabaseScripts
  class FossilProtonymsWithNonFossilTaxa < DatabaseScript
    def results
      Protonym.fossil.joins(:taxa).where(taxa: { fossil: false }).includes(:taxa)
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
category: Protonyms
tags: []

issue_description: (possibly ok) This protonym is fossil, but one of its taxa is extant.

description: >
  This is not necessarily incorrect.

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
