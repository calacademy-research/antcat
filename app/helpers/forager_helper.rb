module ForagerHelper

  def make_index_groups taxa, max_row_count, abbreviated_length
    items_per_row = (taxa.count.to_f / max_row_count).ceil
    taxa.sort_by(&:name).in_groups_of(items_per_row, false).inject([]) do |groups, group|
      if group.size > 1
        label = "#{group.first.name[0, abbreviated_length]}-#{group.last.name[0, abbreviated_length]}"
      else
        label = group.first.name
      end
      groups << {label => group.first.id}
    end
  end

end
