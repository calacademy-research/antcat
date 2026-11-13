# frozen_string_literal: true

# Formats taxon links for the Bolton view of the catalog (/catalog/:id/bolton): status and rank as CSS classes and a
# hover preview.
module BoltonFormatter
  module_function

  def link_to_taxon taxon
    %(<a class="#{taxon_css(taxon)}" href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>).html_safe
  end

  def link_to_taxon_with_label taxon, label
    %(<a class="#{taxon_css(taxon)}" href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end

  def link_to_bolton_taxon_with_label taxon, label
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/catalog/#{taxon.id}/hover_preview.json" \
class="#{taxon_css(taxon)}" \
href="/catalog/#{taxon.id}/bolton">#{label}</a>).html_safe
  end

  def taxon_css taxon
    css_classes = [taxon.status.tr(' ', '-'), taxon.rank]
    css_classes << ['unresolved-homonym'] if taxon.unresolved_homonym?
    css_classes.join(' ')
  end
end
