# frozen_string_literal: true

module CatalogFormatter
  extend ActionView::Helpers::OutputSafetyHelper # For `#safe_join`.

  module_function

  def link_to_taxon taxon
    %(<a class="#{taxon_disco_mode_css(taxon)}" href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>).html_safe
  end

  # TODO: Experimental.
  def link_to_taxa taxa
    safe_join(taxa.map { |taxon| link_to_taxon(taxon) }, ', ')
  end

  def link_to_taxon_with_linked_author_citation taxon
    taxon.decorate.link_to_taxon_with_linked_author_citation
  end

  def link_to_taxon_with_label taxon, label
    %(<a class="#{taxon_disco_mode_css(taxon)}" href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end

  def taxon_disco_mode_css taxon
    css_classes = ['taxon-hover-preview-link', taxon.status.tr(' ', '-')]
    css_classes << ['unresolved-homonym'] if taxon.unresolved_homonym?
    css_classes.join(' ')
  end

  def link_to_protonym protonym
    protonym.decorate.link_to_protonym
  end

  def link_to_protonym_with_linked_author_citation protonym
    protonym.decorate.link_to_protonym_with_linked_author_citation
  end

  def expandable_reference reference
    reference.decorate.expandable_reference.html_safe
  end
end
