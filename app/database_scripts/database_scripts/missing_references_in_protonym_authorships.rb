module DatabaseScripts
  class MissingReferencesInProtonymAuthorships < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Protonym.joins(authorship: :reference)
        .where("references.type = 'MissingReference'")
        .joins(:name).order("names.name")
    end

    def render
      as_table do |t|
        t.header :protonym, :taxon, :taxon_status, :citation, :reference

        t.rows do |protonym|
          taxon = protonym.taxon
          reference = protonym.authorship.reference

          [ protonym.name.protonym_with_fossil_html(protonym.fossil),
            markdown_taxon_link(taxon),
            taxon.try(:status),
            citation_search_link(reference.citation),
            reference_link(reference) ]
        end
      end
    end

    private
      def citation_search_link citation
        search_path = "/references/search?search_type=all&q="
        "<a href='#{search_path}#{URI.encode(citation, /\W/)}'>#{citation}</a>"
      end

      # NOTE duplicated because `#link_to_reference` is a no-op for missing references.
      def reference_link reference
        link_to reference.id, reference_path(reference)
      end
  end
end

__END__
description: >
  Click on the citation in the citation column to search
  for a replacement using AntCat's reference search form.

tags: [regression-test]
topic_areas: [references]
