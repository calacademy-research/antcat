# frozen_string_literal: true

class HistoryPresenter
  attr_private_initialize :history_items

  def grouped_items
    @_grouped_items ||= grouped_items_array.map do |items|
      GroupedHistoryItem.new(items)
    end
  end

  private

    def grouped_items_array
      items = history_items.left_joins(:reference).
        select('history_items.*, references.year AS reference_year, references.date AS reference_date')

      items.
        sort_by { |item| [group_order(item), item.reference_year, item.reference_date] }.
        group_by { |item| group_key(item) }.
        values
    end

    def group_order item
      item.definitions.fetch(:group_order)
    end

    def group_key item
      item.definitions.fetch(:group_key).call(item)
    end
end
