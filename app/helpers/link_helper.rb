module LinkHelper
  def link_to_antwiki taxon
    page_title = if taxon.is_a? Subgenus
                   taxon.name.epithet
                 else
                   taxon.name.name.tr(" ", '_')
                 end
    link_to_external_site 'AntWiki', "http://www.antwiki.org/wiki/#{page_title}"
  end

  def link_to_hol taxon
    return unless taxon.hol_id
    link_to_external_site 'HOL', "http://hol.osu.edu/index.html?id=#{taxon.hol_id}"
  end

  def link_to_antweb taxon
    return if taxon.class.in? [Family, Tribe, Subgenus]

    url = "http://www.antweb.org/description.do?"
    params = { rank: taxon.class.to_s.downcase }
    params.merge! case taxon
                  when Species
                    {      genus: taxon.genus.name.name.downcase,
                         species: taxon.name.epithet.downcase }
                  when Subspecies
                    return unless taxon.species
                    {      genus: taxon.genus.name.name.downcase,
                         species: taxon.species.name.epithet,
                      subspecies: taxon.name.subspecies_epithets.downcase }
                  when Genus
                    {      genus: taxon.name.name.downcase }
                  when Subfamily
                    {  subfamily: taxon.name.name.downcase }
                  else
                    raise "Don't know how to link #{taxon} to AntWeb"
                  end

    params[:project] = "worldants"

    # Rails' .to_param sorts the params, this one doesn't
    url << params.map { |key, value| value.to_query(key) }.compact * '&'
    link_to_external_site 'AntWeb', url.html_safe
  end

  private

    def link_to_external_site label, url
      link_to label, url, class: 'link_to_external_site'
    end
end
