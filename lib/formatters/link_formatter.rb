# coding: UTF-8
module Formatters::LinkFormatter
  include ActionView::Helpers::TagHelper
  include ERB::Util

  def link contents, href, attributes = {}
    attributes = attributes.dup
    attributes[:target] = '_blank' unless attributes.include? :target
    attributes.delete(:target) if attributes[:target].nil?
    attributes[:href] = href
    attributes_string = attributes.keys.sort.inject(''.html_safe) do |string, key|
      string << "#{key}=\"#{h attributes[key]}\" ".html_safe
    end.strip.html_safe
    '<a '.html_safe + attributes_string + '>'.html_safe + contents + '</a>'.html_safe
  end

  def link_to_external_site label, url
    link label, url, class: 'link_to_external_site'
  end

  def link_to_reference reference, user
    reference.key.to_link user, expansion: expand_references?
  end

  def link_to_antcat taxon, label = 'AntCat'
    link_to_external_site label, "http://www.antcat.org/catalog/#{taxon.id}"
  end

  def link_to_antwiki taxon
    link_to_external_site 'AntWiki', "http://www.antwiki.org/wiki/#{taxon.name.to_s.gsub(/ /, '_')}"
  end

  def link_to_antweb taxon
    return if taxon.kind_of? Family
    url = %{http://www.antweb.org/description.do?}
    url << case taxon
    when Species
      %{rank=species&genus=#{taxon.genus.name.to_s.downcase}&species=#{taxon.name.epithet.to_s.downcase}}
    when Subspecies
      return unless taxon.species
      %{rank=subspecies} + '&' +
      %{genus=#{taxon.genus.name.to_s.downcase}} + '&' +
      %{species=#{taxon.species.name.epithet}} + '&' +
      %{subspecies=#{taxon.name.subspecies_epithets.to_s.downcase}}
    when Subgenus
      %{rank=subgenus&genus=#{taxon.genus.name.to_s.downcase}&subgenus=#{taxon.name.to_s.downcase}}
    when Genus
      %{rank=genus&genus=#{taxon.name.to_s.downcase}}
    when Tribe
      %{rank=tribe&tribe=#{taxon.name.to_s.downcase}}
    when Subfamily
      %{rank=subfamily&subfamily=#{taxon.name.to_s.downcase}}
    else
      raise "Don't know how to link #{taxon} to AntWeb"
    end
    url << %{&project=worldants}
    link_to_external_site 'AntWeb', url.html_safe
  end

end
