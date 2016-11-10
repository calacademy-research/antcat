module LinkHelper
  include ActionView::Helpers::UrlHelper

  # TODO something. We kind of do not want this, I think, because:
  # * It's non-standard and confusing.
  # * No one likes `target: '_blank'`.
  # * The name is hard to grep (search for "LinkHelper#link.")
  #
  # But it will be hard to remove because loads of tests have to be
  # be rewritten and it's also used for the AntWeb export.
  def link contents, href, options = {}
    link_to contents, href,
      class:  options[:class],
      target: options[:target],
      title:  options[:title]
  end

  def link_to_external_site label, url
    link label, url, class: 'link_to_external_site', target: '_blank'
  end

  def link_to_antwiki taxon
    page_title = taxon.name.to_s.gsub(/ /, '_')
    link_to_external_site 'AntWiki', "http://www.antwiki.org/wiki/#{page_title}"
  end

  def link_to_hol taxon
    return unless hol_id = taxon.hol_id
    link_to_external_site 'HOL', "http://hol.osu.edu/index.html?id=#{hol_id}"
  end

  def link_to_antweb taxon
    return if taxon.class.in? [Family, Tribe, Subgenus]

    url = "http://www.antweb.org/description.do?"
    params = { rank: taxon.class.to_s.downcase }
    params.merge! case taxon
                  when Species
                    {      genus: taxon.genus.name.to_s.downcase,
                         species: taxon.name.epithet.to_s.downcase }
                  when Subspecies
                    return unless taxon.species
                    {      genus: taxon.genus.name.to_s.downcase,
                         species: taxon.species.name.epithet,
                      subspecies: taxon.name.subspecies_epithets.to_s.downcase }
                  when Genus
                    {      genus: taxon.name.to_s.downcase }
                  when Subfamily
                    {  subfamily: taxon.name.to_s.downcase }
                  else
                    raise "Don't know how to link #{taxon} to AntWeb"
                  end

    params[:project] = "worldants"

    # Rails' .to_param sorts the params, this one doesn't
    url << params.map { |key, value| value.to_query(key) }.compact * '&'
    link_to_external_site 'AntWeb', url.html_safe
  end
end
