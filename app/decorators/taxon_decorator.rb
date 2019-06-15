class TaxonDecorator < Draper::Decorator
  delegate_all

  def link_to_taxon
    link_to_taxon_with_label taxon.name_with_fossil
  end

  def link_to_taxon_with_label label
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def link_to_taxon_with_author_citation
    link_to_taxon_with_label(taxon.name_with_fossil) << ' ' << taxon.author_citation.html_safe
  end

  def id_and_name_and_author_citation
    h.content_tag :span do
      h.concat h.content_tag(:small, "##{taxon.id}", class: "gray")
      h.concat " "
      h.concat link_to_taxon
      h.concat " "
      h.concat h.content_tag(:small, author_citation, class: "gray")
    end
  end

  def type_taxon_rank
    type_rank = type_taxon.is_a?(Subgenus) ? 'genus' : type_taxon.rank
    "Type-#{type_rank}: ".html_safe
  end

  # NOTE: We need this becuase `type_taxt` is stripped of leading whitespace.
  def format_type_taxt
    return if type_taxt.blank?
    return type_taxt if type_taxt.start_with?(",")
    " " << type_taxt
  end

  def statistics valid_only: false
    stats = Taxa::FetchStatistics[taxon, valid_only: valid_only]
    Taxa::FormatStatistics[stats]
  end

  def taxon_status
    Taxa::TaxonStatus[taxon]
  end

  def link_to_antwiki
    page_title = if taxon.is_a? Subgenus
                   taxon.name.epithet
                 else
                   taxon.name.name.tr(" ", '_')
                 end
    h.external_link_to 'AntWiki', "http://www.antwiki.org/wiki/#{page_title}"
  end

  def link_to_hol
    return unless taxon.hol_id
    h.external_link_to 'HOL', "http://hol.osu.edu/index.html?id=#{taxon.hol_id}"
  end

  def link_to_antweb
    return if taxon.class.in? [Family, Tribe, Subgenus]

    url = "http://www.antweb.org/description.do?"
    params = { rank: taxon.rank }
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
    h.external_link_to 'AntWeb', url.html_safe
  end

  def link_to_google_scholar
    params = { q: "#{taxon.name_cache} #{taxon.author_citation}" }.to_query
    h.external_link_to "Google&nbsp;Scholar".html_safe, "//scholar.google.com/scholar?#{params}"
  end
end
