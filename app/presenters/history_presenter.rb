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

    # Groups follow the order editors set (`position`): a group is placed where its
    # earliest item is. Inside a group (e.g. several citations of "Combination in X"),
    # items are sorted by reference year; within one year they keep the editors' order.
    # Reference dates are not used there: many are missing or less precise than a day
    # (YYYY, YYYYMM), so they cannot decide the order reliably.
    #
    # Editors' order is used for groups, not the type's `group_order`, because most
    # history items are still free text. Sorting structured items by type put them
    # above all free-text items, so converting a line moved it on the page.
    #
    # `position` is scoped per protonym, so it only means something when all items
    # belong to one protonym. Lists that mix protonyms (items shown "as object" on
    # another taxon's page) keep the type, year, date order.
    def grouped_items_array
      items = history_items.left_joins(:reference).
        select('history_items.*, references.year AS reference_year, references.date AS reference_date')

      groups = items.group_by { |item| item.group_key(template_name) }.values

      group_sort_key = single_protonym?(items) ? method(:editor_sort_key) : method(:type_sort_key)

      item_sort_key = single_protonym?(items) ? method(:year_then_editor_sort_key) : method(:chronological_sort_key)

      groups.map { |group| group.sort_by(&item_sort_key) }.
        sort_by { |group| group.map(&group_sort_key).min }
    end

    def single_protonym? items
      items.map(&:protonym_id).uniq.size <= 1
    end

    def type_sort_key item
      [item.definition.group_order, *chronological_sort_key(item)]
    end

    def chronological_sort_key item
      [
        (item.reference_year || -1),
        (Integer(item.reference_date, exception: false) || -1).to_s,
        # Ruby's sort is not stable, so ties are broken by the order editors set.
        item.position || 0,
        item.id
      ]
    end

    def year_then_editor_sort_key item
      [(item.reference_year || -1), *editor_sort_key(item)]
    end

    # `position` is NOT NULL in the schema; a missing one would sort last rather than first.
    def editor_sort_key item
      [item.position.nil? ? 1 : 0, item.position || 0, item.id]
    end
end
