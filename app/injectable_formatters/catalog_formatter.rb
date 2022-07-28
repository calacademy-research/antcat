# frozen_string_literal: true

module CatalogFormatter
  extend ActionView::Helpers::OutputSafetyHelper # For `#safe_join`.

  module_function

  def link_to_taxon taxon
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/catalog/#{taxon.id}/hover_preview.json" \
class="#{taxon_disco_mode_css(taxon)}" \
href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>).html_safe
  end

  def link_to_taxa taxa
    safe_join(taxa.map { |taxon| link_to_taxon(taxon) }, ', ')
  end

  def link_to_taxon_with_linked_author_citation taxon
    link_to_taxon(taxon) <<
      %( <span class="discret-author-citation">#{link_to_reference(taxon.authorship_reference)}</span>).html_safe
  end

  def link_to_taxon_with_label taxon, label
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/catalog/#{taxon.id}/hover_preview.json" \
class="#{taxon_disco_mode_css(taxon)}" \
href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end

  def taxon_disco_mode_css taxon
    css_classes = [taxon.status.tr(' ', '-')]
    css_classes << ['unresolved-homonym'] if taxon.unresolved_homonym?
    css_classes.join(' ')
  end

  def link_to_protonym protonym
    protonym.decorate.link_to_protonym
  end

  def link_to_protonym_with_linked_author_citation protonym
    protonym.decorate.link_to_protonym_with_linked_author_citation
  end

  def link_to_protonym_with_terminal_taxa protonym
    terminal_taxa_links = link_to_taxa(protonym.terminal_taxa).presence || 'no terminal taxon'
    protonym.decorate.link_to_protonym << " (" << terminal_taxa_links << ")"
  end

  def link_to_reference reference
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/references/#{reference.id}/hover_preview.json" \
href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>).html_safe
  end

  def link_to_taxt_reference reference
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/references/#{reference.id}/hover_preview.json" \
class="taxt-hover-reference" \
href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>).html_safe
  end

  # HACK: Performance hack for as long as we have history items with a lot of ref-tags.
  def link_to_taxt_reference_cached reference_id, key_with_suffixed_year_cache
    %(<a data-controller="hover-preview" \
data-hover-preview-url-value="/references/#{reference_id}/hover_preview.json" \
class="taxt-hover-reference" \
href="/references/#{reference_id}">#{key_with_suffixed_year_cache}</a>)
  end
end
