# frozen_string_literal: true

class TaxonDecorator < Draper::Decorator
  ANTWIKI_BASE_URL = "https://www.antwiki.org/wiki/"
  HOL_BASE_URL = "http://hol.osu.edu/index.html?id="
  ANTWEB_BASE_URL = "https://www.antweb.org/description.do?"
  GOOGLE_SCHOLAR_BASE_URL = "//scholar.google.com/scholar?"

  def link_to_taxon_with_label label
    h.link_to label, h.catalog_path(taxon)
  end

  def link_to_taxon_with_author_citation
    link_to_taxon_with_label(taxon.name_with_fossil) << ' ' << taxon.author_citation.html_safe
  end

  def link_to_taxon_with_linked_author_citation
    link_to_taxon_with_label(taxon.name_with_fossil) <<
      ' ' <<
      h.content_tag(
        :span,
        h.link_to(taxon.author_citation.html_safe, h.reference_path(taxon.authorship_reference)),
        class: 'discret-author-citation'
      )
  end

  def id_and_name_and_author_citation
    h.content_tag :span do
      h.concat h.content_tag(:small, "##{taxon.id}", class: "gray")
      h.concat " "
      h.concat taxon.link_to_taxon
      h.concat " "
      h.concat h.content_tag(:small, taxon.author_citation, class: "gray")
    end
  end

  def collected_references
    Taxa::CollectReferences[taxon]
  end

  def type_taxon_rank
    "Type-#{taxon.type_taxon.rank}: ".html_safe
  end

  # NOTE: We need this because `type_taxt` is stripped of leading whitespace.
  def format_type_taxt
    return unless (type_taxt = taxon.type_taxt)
    return type_taxt if type_taxt.start_with?(",")
    " " + type_taxt
  end

  def statistics valid_only: false
    stats = Taxa::Statistics::FetchStatistics[taxon, valid_only: valid_only]
    Taxa::Statistics::FormatStatistics[stats]
  end

  def link_to_antwiki
    page_title = if taxon.is_a? Subgenus
                   taxon.name.epithet
                 else
                   taxon.name_cache.tr(" ", '_')
                 end
    h.external_link_to 'AntWiki', "#{ANTWIKI_BASE_URL}#{page_title}"
  end

  def link_to_hol
    return unless taxon.hol_id
    h.external_link_to 'HOL', "#{HOL_BASE_URL}#{taxon.hol_id}"
  end

  def link_to_antweb
    return if taxon.class.in? [Family, Tribe, Subtribe, Subgenus, Infrasubspecies]

    params = { rank: taxon.rank }
    params.merge! case taxon
                  when Species
                    { genus: taxon.genus.name_cache, species: taxon.name.epithet }
                  when Subspecies
                    {
                      genus: taxon.genus.name_cache,
                      species: taxon.species.name.epithet,
                      subspecies: taxon.name.subspecies_epithets
                    }
                  when Genus
                    { genus: taxon.name_cache }
                  when Subfamily
                    { subfamily: taxon.name_cache }
                  else
                    raise "Don't know how to link #{taxon} to AntWeb"
                  end

    params[:project] = "worldants"

    # Rails' .to_param sorts the params, this one doesn't
    url = ANTWEB_BASE_URL + params.map { |key, value| value.to_query(key) }.compact * '&'
    h.external_link_to 'AntWeb', url.downcase.html_safe
  end

  def link_to_google_scholar
    params = { q: "#{taxon.name_cache} #{taxon.author_citation}" }.to_query
    h.external_link_to "Google&nbsp;Scholar".html_safe, "#{GOOGLE_SCHOLAR_BASE_URL}#{params}"
  end
end
