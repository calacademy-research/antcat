# frozen_string_literal: true

module DefaultFormatter
  module_function

  def link_to_taxon taxon
    taxon.link_to_taxon
  end

  def link_to_taxon_with_label taxon, label
    %(<a href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end
end
