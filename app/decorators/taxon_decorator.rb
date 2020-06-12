# frozen_string_literal: true

class TaxonDecorator < Draper::Decorator
  ANTWIKI_BASE_URL = "https://www.antwiki.org/wiki/"
  HOL_BASE_URL = "http://hol.osu.edu/index.html?id="
  ANTWEB_BASE_URL = "https://www.antweb.org/description.do?"
  GOOGLE_SCHOLAR_BASE_URL = "//scholar.google.com/scholar?"

  def link_to_taxon_with_author_citation
    CatalogFormatter.link_to_taxon(taxon) << ' ' << taxon.author_citation.html_safe
  end

  def link_to_taxon_with_linked_author_citation
    CatalogFormatter.link_to_taxon(taxon) <<
      ' ' <<
      h.tag.span(
        h.link_to(taxon.author_citation.html_safe, h.reference_path(taxon.authorship_reference)),
        class: 'discret-author-citation'
      )
  end

  def id_and_name_and_author_citation
    h.tag.span do
      h.concat h.tag.small("##{taxon.id}", class: "gray")
      h.concat " "
      h.concat CatalogFormatter.link_to_taxon(taxon)
      h.concat " "
      h.concat h.tag.small(taxon.author_citation, class: "gray")
    end
  end

  def expanded_status
    Taxa::ExpandedStatus[taxon]
  end

  def compact_status
    Taxa::CompactStatus[taxon]
  end

  def full_statistics
    Taxa::Statistics::FetchStatistics[taxon]
  end

  def valid_only_statistics
    Taxa::Statistics::FetchStatistics[taxon, valid_only: true]
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
    return unless (hol_id = taxon.hol_id)
    h.external_link_to 'HOL', "#{HOL_BASE_URL}#{hol_id}"
  end

  def link_to_antweb
    return if taxon.class.in? [Family, Tribe, Subtribe, Subgenus, Infrasubspecies]

    # Rails' `Hash#to_param` sorts the params, this one doesn't
    query_string = antweb_params.map { |key, value| value.to_query(key) }.compact * '&'
    h.external_link_to 'AntWeb', (ANTWEB_BASE_URL + query_string).downcase.html_safe
  end

  def link_to_google_scholar
    params = { q: "#{taxon.name_cache} #{taxon.author_citation}" }.to_query
    h.external_link_to "Google&nbsp;Scholar".html_safe, "#{GOOGLE_SCHOLAR_BASE_URL}#{params}"
  end

  private

    def antweb_params
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
      params
    end
end
