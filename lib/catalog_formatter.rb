# coding: UTF-8
class CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context

  # AntWeb
  def self.format_taxonomic_history_for_antweb taxon
    string = taxon.taxonomic_history
    string << format_homonym_replaced_for_antweb(taxon)
    string.html_safe if string
  end

  def self.format_homonym_replaced_for_antweb taxon
    homonym_replaced = taxon.homonym_replaced
    return '' unless homonym_replaced
    label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
    span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
    string = %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
    string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.taxonomic_history}</div>}
    string
  end

  def self.format_taxonomic_history_with_statistics_for_antweb taxon, options = {}
    format_taxon_statistics(taxon, options) + format_taxonomic_history_for_antweb(taxon)
  end

  ########################################################################

  def self.format_taxon_statistics taxon, options = {}
    return '' unless taxon
    statistics = taxon.statistics
    return '' unless statistics
    format_statistics statistics, options
  end

  def self.format_statistics statistics, options = {}
    options.reverse_merge! :include_invalid => true, :include_fossil => true
    return '' unless statistics && statistics.present?
    strings = [:extant, :fossil].inject({}) do |strings, extant_or_fossil|
      extant_or_fossil_statistics = statistics[extant_or_fossil]
      if extant_or_fossil_statistics
        string = [:subfamilies, :genera, :species, :subspecies].inject([]) do |rank_strings, rank|
          string = format_rank_statistics(extant_or_fossil_statistics, rank, options[:include_invalid])
          rank_strings << string if string.present?
          rank_strings
        end.join ', '
        strings[extant_or_fossil] = string
      end
      strings
    end
    strings = if strings[:extant] && strings[:fossil] && options[:include_fossil]
      strings[:extant].insert 0, 'Extant: '
      strings[:fossil].insert 0, 'Fossil: '
      [strings[:extant], strings[:fossil]]
    elsif strings[:extant]
      [strings[:extant]]
    elsif options[:include_fossil]
      ['Fossil: ' + strings[:fossil]]
    else
      []
    end
    strings.map do |string|
      content_tag('p', string, :class => 'taxon_statistics')
    end.join.html_safe
  end

  def self.format_rank_statistics statistics, rank, include_invalid
    statistics = statistics[rank]
    return unless statistics

    string = ''

    if statistics['valid']
      string << format_rank_status_count(rank, 'valid', statistics['valid'], include_invalid)
      statistics.delete 'valid'
    end

    return string unless include_invalid

    status_strings = statistics.keys.sort_by do |key|
      ordered_statuses.index key
    end.inject([]) do |status_strings, status|
      status_strings << format_rank_status_count(:genera, status, statistics[status])
    end

    if status_strings.present?
      string << ' ' if string.present?
      string << "(#{status_strings.join(', ')})"
    end

    string.present? && string
  end

  def self.format_rank_status_count rank, status, count, label_statuses = true
    rank = :subfamily if rank == :subfamilies and count == 1
    rank = :genus if rank == :genera and count == 1
    if label_statuses
      count_and_status = pluralize_with_delimiters count, status, status == 'valid' ? status : status_plural(status)
    else
      count_and_status = number_with_delimiter count
    end
    string = count_and_status
    string << " #{rank.to_s}" if status == 'valid'
    string
  end

  def self.taxon_label_and_css_classes taxon, options = {}
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if options[:selected]
    name = taxon.name.dup
    name.upcase! if options[:uppercase]
    label = fossil_symbol + h(name)
    {:label => label.html_safe, :css_classes => css_classes_for_taxon(taxon, options[:selected])}
  end

  def self.css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon']
  end

  def self.status_plural status
    status_labels[status][:plural]
  end

  def self.status_labels
    @status_labels || begin
      @status_labels = ActiveSupport::OrderedHash.new
      @status_labels['synonym']             = {:singular => 'synonym', :plural => 'synonyms'}
      @status_labels['homonym']             = {:singular => 'homonym', :plural => 'homonyms'}
      @status_labels['unavailable']         = {:singular => 'unavailable', :plural => 'unavailable'}
      @status_labels['unidentifiable']      = {:singular => 'unidentifiable', :plural => 'unidentifiable'}
      @status_labels['excluded']            = {:singular => 'excluded', :plural => 'excluded'}
      @status_labels['unresolved homonym']  = {:singular => 'unresolved homonym', :plural => 'unresolved homonyms'}
      @status_labels['recombined']          = {:singular => 'transferred out of this genus', :plural => 'transferred out of this genus'}
      @status_labels['nomen nudum']         = {:singular => 'nomen nudum', :plural => 'nomina nuda'}
      @status_labels
    end
  end

  def self.ordered_statuses
    status_labels.keys
  end

  def self.pluralize_with_delimiters count, word, plural = nil
    if count != 1
      word = plural ? plural : word.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

  ###################################################
  def self.format_headline taxon, user
    format_headline_protonym(taxon, user) + ' ' + format_headline_type(taxon)
  end

  def self.format_headline_protonym taxon, user
    return '' unless taxon
    string = format_headline_name(taxon)
    string << ' ' << format_headline_authorship(taxon.protonym.authorship, user) if taxon.protonym
    string
  end

  def self.format_headline_name taxon
    return '' unless taxon && taxon != 'no_tribe' && taxon != 'no_subfamily' && taxon.protonym
    content_tag :span, taxon.protonym.name, :class => :family_group_name
  end

  def self.format_headline_authorship authorship, user
    return '' unless authorship
    content_tag :span, authorship.reference.key.to_link(user) +
      ": #{authorship.pages}.".html_safe, :class => :authorship
  end

  def self.format_headline_type taxon
    return '' unless taxon
    content_tag :span, :class => :type do
      'Type-genus: '.html_safe +
      format_genus_name(taxon.type_taxon) +
      '.'.html_safe
    end
  end

  def self.format_genus_name genus
    content_tag(:span, genus.name, :class => :genus_name).html_safe
  end

  def self.format_reference_document_link reference, user
    "<a class=\"document_link\" target=\"_blank\" href=\"#{reference.url}\">PDF</a>" if reference.downloadable_by? user
  end

  ###################################################

  def self.format_status taxon
    taxon && taxon.invalid? ? status_labels[taxon.status][:singular] : ''
  end

  def self.format_taxon taxon, current_user
    full_label        = taxon ? taxon.full_label : ''
    taxon_status      = format_status taxon
    headline          = format_headline taxon, current_user
    taxonomic_history = format_taxonomic_history taxon, current_user
    statistics        = format_taxon_statistics taxon
    content_tag :div, :class => :antcat_taxon do
      contents = ''
      contents << content_tag(:div, :class => :header) do
        content_tag(:span, full_label,        :class => :name) +
        content_tag(:span, taxon_status,      :class => :status)
      end
      contents << content_tag(:div,  statistics,        :class => :statistics)
      contents << content_tag(:div,  headline,          :class => :headline)
      contents << content_tag(:h4,  'Taxonomic history')
      contents << content_tag(:div,  taxonomic_history, :class => :taxonomic_history)
      contents.html_safe
    end
  end

  def self.format_taxonomic_history_item taxt, user
    string = Taxt.interpolate taxt, user
    string << '.'
    content_tag :div, string.html_safe, :class => :taxonomic_history_item
  end

  def self.format_taxonomic_history taxon, user
    return '' unless taxon
    taxon.taxonomic_history_items.inject('') do |string, taxonomic_history_item|
      string << format_taxonomic_history_item(taxonomic_history_item.taxt, user)
    end.html_safe
  end

  ###################################################

  private
  def self.css_classes_for_taxon taxon, selected = false
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    css_classes = css_classes.sort.join ' '
  end

end
