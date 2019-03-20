class TableRefDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def initialize table, field, id
    @table = table
    @field = field
    @id = id
  end

  def item_link
    return "id_missing" unless id

    case table
    when "citations"           then id
    when "protonyms"           then link_to(id, protonym_path(id))
    when "reference_sections"  then link_to(id, reference_section_path(id))
    when "references"          then link_to(id, reference_path(id))
    when "synonyms", "taxa"    then link_to(id, catalog_path(id))
    when "taxon_history_items" then link_to(id, taxon_history_item_path(id))
    else                            "#{id} ???"
    end
  end

  def related_links
    return "id_missing" unless id

    case table
    when "citations"           then related_citation_link
    when "protonyms"           then related_protonym_link
    when "reference_sections"  then ReferenceSection.find(id).taxon.decorate.link_to_taxon
    when "references"          then Reference.find(id).decorate.expandable_reference
    when "synonyms", "taxa"    then Taxon.find(id).decorate.link_to_taxon
    when "taxon_history_items" then TaxonHistoryItem.find(id).taxon.decorate.link_to_taxon
    else                            "#{table} ???"
    end
  end

  private

    attr_reader :table, :field, :id

    def related_citation_link
      citation = Citation.find(id)

      citation.protonym.taxa.map do |taxon|
        taxon.decorate.link_to_taxon
      end.join(', ').html_safe
    end

    def related_protonym_link
      protonym = Protonym.find(id)
      link_to "Protonym: ".html_safe << protonym.decorate.format_name, protonym_path(protonym)
    end
end
