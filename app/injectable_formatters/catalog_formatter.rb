# frozen_string_literal: true

module CatalogFormatter
  module_function

  def link_to_taxon taxon
    %(<a class="#{disco_mode_css(taxon)}" href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a>).html_safe
  end

  def link_to_taxon_with_label taxon, label
    %(<a class="#{disco_mode_css(taxon)}" href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end

  def disco_mode_css taxon
    css_classes = [taxon.status.tr(' ', '-')]
    css_classes << ['unresolved-homonym'] if taxon.unresolved_homonym?
    css_classes.join(' ')
  end
end
