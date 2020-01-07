module DatabaseScripts
  class ProtonymsWithTaxaWithVeryDifferentEpithets < DatabaseScript
    def results
      Protonym.joins(taxa: :name).
        where(taxa: { type: 'Species' }).
        group('protonyms.id').having("COUNT(DISTINCT SUBSTR(names.epithet, 1, 3)) > 1")
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :epithets_of_taxa, :ranks_of_taxa, :statuses_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.joins(:name).pluck(:epithet).join(', '),
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: [new!]

issue_description: The taxa of this protonym have very different epithets.

description: >
  "Very different" means that the first three letters in the epithet are not the same.


  Only species checked.

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
