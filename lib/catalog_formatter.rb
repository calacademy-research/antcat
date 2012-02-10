# coding: UTF-8
class CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper

  def self.format_taxonomic_history taxon
    string = taxon.taxonomic_history
    homonym_replaced = taxon.homonym_replaced
    if homonym_replaced
      label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
      span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
      string << %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
      string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.taxonomic_history}</div>}
    end
    string.html_safe if string
  end

  def self.format_taxonomic_history_with_statistics taxon, options = {}
    format_taxon_statistics(taxon, options) + format_taxonomic_history(taxon)
  end

  def self.format_taxon_statistics taxon, options = {}
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
    end.join
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

  def self.fossil name, is_fossil
    string = ''
    string << '&dagger;' if is_fossil
    string << h(name)
    string.html_safe
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

  private
  def self.css_classes_for_taxon taxon, selected = false
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    css_classes = css_classes.sort.join ' '
  end

end
