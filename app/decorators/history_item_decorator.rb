# frozen_string_literal: true

class HistoryItemDecorator < Draper::Decorator
  def rank_specific_badge
    return unless history_item.rank?

    h.tag.span(class: 'bg-logged-in-only') do
      h.tag.small "#{history_item.rank}-only item", class: 'bold-notice'
    end
  end

  def params_for_add_another_of_same_type
    {
      position: history_item.position + 1,
      type: history_item.type,
      subtype: history_item.subtype,
      object_protonym_id: history_item.object_protonym_id,
      object_taxon_id: history_item.object_taxon_id
    }.compact
  end
end
