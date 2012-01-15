# coding: UTF-8
require 'snake'

module Catalog::BrowserHelper

  def make_index_groups taxa, max_row_count, abbreviated_length
    items_per_row = (taxa.count.to_f / max_row_count).ceil
    return [] if items_per_row.zero?
    groups = taxa.sort_by(&:name).in_groups_of(items_per_row, false)
    any_groups_with_more_than_one_member = false
    groups.inject([]) do |label_groups, group|
      result = {:id => group.first.id}
      label_and_classes = CatalogFormatter.taxon_label_and_css_classes group.first
      any_groups_with_more_than_one_member ||= group.size > 1
      if any_groups_with_more_than_one_member
        if group.size > 1
          result[:label] = "#{group.first.name[0, abbreviated_length]}-#{group.last.name[0, abbreviated_length]}"
          result[:css_classes] = CatalogFormatter.css_classes_for_rank(group.first).join ' '
        else
          result.merge! label_and_classes
          result[:css_classes] = CatalogFormatter.css_classes_for_rank(group.first).join ' '
        end
      else
        result.merge! label_and_classes
      end
      label_groups << result
    end
  end

  def browser_taxon_header taxon, options = {}
    label_and_css_classes = CatalogFormatter.taxon_label_and_css_classes taxon, :uppercase => true
    if options[:link]
      (taxon.rank.capitalize + ' ' + link_to(label_and_css_classes[:label], browser_catalog_path(taxon, options[:search_params]), :class => label_and_css_classes[:css_classes])).html_safe
    else
      (taxon.rank.capitalize + ' ' + content_tag('span', label_and_css_classes[:label], :class => label_and_css_classes[:css_classes])).html_safe
    end
  end

end
