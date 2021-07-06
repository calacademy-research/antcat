# frozen_string_literal: true

module HistoryItemHelper
  def options_for_history_item_types value
    options = History::Definitions::TYPE_DEFINITIONS.each_with_object({}) do |(type, definition), memo|
      ranks = definition[:ranks]
      memo[ranks] ||= []
      memo[ranks] << [definition[:type_label], type]
    end

    grouped_options_for_select(options, value)
  end

  def tr_for_reference_and_pages history_item
    render partial: "history_items/edit_templates/shared/reference_and_pages", locals: { history_item: history_item }
  end

  def tr_for_optional_reference_and_pages history_item
    render partial: "history_items/edit_templates/shared/optional_reference_and_pages", locals: { history_item: history_item }
  end

  def collapse_history_item_taxt_textarea? history_item
    return true if relational_history_item_without_taxt?(history_item)
    return false if is_or_was_taxt_history_item?(history_item)
  end

  private

    def relational_history_item_without_taxt? history_item
      history_item.relational? && history_item.taxt.blank?
    end

    def is_or_was_taxt_history_item? history_item
      History::Definitions::TAXT.in?([history_item.type, history_item.type_was])
    end
end
