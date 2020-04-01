# frozen_string_literal: false

# TODO: Cleanup. This is more of a dumping ground than an actual decorator.

class TaxonDecorator < Draper::Decorator
  def link_to_taxon_with_label label
    h.link_to label, h.catalog_path(taxon)
  end

  def link_to_taxon_with_author_citation
    link_to_taxon_with_label(taxon.name_with_fossil) << ' ' << taxon.author_citation.html_safe
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
    type_taxt = taxon.type_taxt
    return if type_taxt.blank?
    return type_taxt if type_taxt.start_with?(",")
    " " << type_taxt
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
    h.external_link_to 'AntWiki', "https://www.antwiki.org/wiki/#{page_title}"
  end

  def link_to_hol
    return unless taxon.hol_id
    h.external_link_to 'HOL', "http://hol.osu.edu/index.html?id=#{taxon.hol_id}"
  end

  def link_to_antweb
    return if taxon.class.in? [Family, Tribe, Subtribe, Subgenus, Infrasubspecies]

    url = "https://www.antweb.org/description.do?"
    params = { rank: taxon.rank }
    params.merge! case taxon
                  when Species
                    { genus: taxon.genus.name.name.downcase, species: taxon.name.epithet.downcase }
                  when Subspecies
                    {
                      genus: taxon.genus.name.name.downcase,
                      species: taxon.species.name.epithet,
                      subspecies: taxon.name.subspecies_epithets.downcase
                    }
                  when Genus
                    { genus: taxon.name.name.downcase }
                  when Subfamily
                    { subfamily: taxon.name.name.downcase }
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
