# frozen_string_literal: true

module HistoryItemHelper
  def tr_for_reference_and_pages history_item
    render partial: "history_items/edit_templates/reference_and_pages", locals: { history_item: history_item }
  end

  def collapse_history_item_taxt_textarea? history_item
    return true if hybrid_history_item_without_taxt?(history_item)
    return false if is_or_was_taxt_history_item?(history_item)
  end

  private

    def hybrid_history_item_without_taxt? history_item
      history_item.hybrid? && history_item.taxt.blank?
    end

    def is_or_was_taxt_history_item? history_item
      HistoryItem::TAXT.in?([history_item.type, history_item.type_was])
    end
end
