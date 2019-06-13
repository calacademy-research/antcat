module DatabaseScripts
  class ConflictingBiogeographicRegions < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      conflicts = Protonym.joins(:taxa).group(:protonym_id).having('COUNT(DISTINCT biogeographic_region) > 1')
      Protonym.where(id: conflicts.select(:protonym_id))
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :taxa, :biogeographic_regions
        t.rows do |protonym|
          [
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.map { |taxon| taxon.decorate.link_to_taxon }.join('<br>'),
            protonym.taxa.map { |taxon| taxon.biogeographic_region.presence || '-' }.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

description: >
  Taxa with `biogeographic_region`s that cannot be merged into the protonym by script.

tags: [new!]
topic_areas: [protonyms]
