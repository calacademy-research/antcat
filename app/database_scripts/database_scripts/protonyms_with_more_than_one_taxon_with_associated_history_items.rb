module DatabaseScripts
  class ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems < DatabaseScript
    def results
      Protonym.distinct.joins(:taxa).
        where(taxa: { id: Taxon.joins(:history_items).select(:id) }).
        group("protonyms.id").having("COUNT(protonyms.id) > 1")
    end

    def render
      as_table do |t|
        t.header :protonym, :ranks_of_taxa, :taxa, :statuses_of_taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.taxa.distinct.pluck(:type).join(', '),
            protonym.taxa.map(&:link_to_taxon).join('<br>'),
            protonym.taxa.map(&:status).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms

issue_description: (possibly ok) More than one of this protonym's taxa have history items.

description: >
  Go to the protonym's page to see all history items in one place.
