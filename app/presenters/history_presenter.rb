# frozen_string_literal: true

class HistoryPresenter
  def initialize history_items, template_name = :default
    @history_items = history_items
    @template_name = template_name
  end

  def grouped_items
    @_grouped_items ||= grouped_items_array.map do |items|
      GroupedHistoryItem.new(items)
    end
  end

  private

    attr_reader :history_items, :template_name

    def grouped_items_array
      items = history_items.left_joins(:reference).
        select('history_items.*, references.year AS reference_year, references.date AS reference_date')

      items.sort_by do |item|
        [
          item.definition.group_order,
          (item.reference_year || -1),
          (Integer(item.reference_date, exception: false) || -1).to_s
        ]
      end.group_by { |item| item.group_key(template_name) }.values
    end
end
