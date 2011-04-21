module ForagerHelper

  def make_index_groups taxa, max_row_count, abbreviated_length
    items_per_row = (taxa.count.to_f / max_row_count).ceil
    taxa.sort_by(&:name).in_groups_of(items_per_row, false).inject([]) do |groups, group|
      result = {:id => group.first.id}
      if group.size > 1
        result[:css_classes] = taxon_rank_css_classes(group.first).join ' '
        result[:label] = "#{group.first.name[0, abbreviated_length]}-#{group.last.name[0, abbreviated_length]}"
      else
        result.merge! taxon_label_and_css_classes group.first
      end
      groups << result
    end
  end

end
