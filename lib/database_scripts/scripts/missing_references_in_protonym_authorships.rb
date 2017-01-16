class DatabaseScripts::Scripts::MissingReferencesInProtonymAuthorships
  include DatabaseScripts::DatabaseScript

  def results
    Protonym.joins(authorship: :reference)
      .where("references.type = 'MissingReference'")
      .joins(:name).order("names.name")
  end

  def render
    as_table do
      header :protonym, :taxon, :taxon_status, :citation, :reference

      rows do |protonym|
        taxon = protonym.taxon
        reference = protonym.authorship.reference

        [ protonym.name.protonym_with_fossil_html(protonym.fossil),
          markdown_taxon_link(taxon),
          taxon.status,
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

    # HACK because `#link_to_reference` is a no-op for missing references.
    def reference_link reference
      ReferenceDecorator.new(reference).link_to_reference
    end
end

__END__
description: >
  Click on the citation in the citation column to search
  for a replacement using AntCat's reference search form.

tags: [new!]
topic_areas: [catalog, references]
