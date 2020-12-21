# frozen_string_literal: true

class HistoryItemDecorator < Draper::Decorator
  def rank_specific_badge
    return unless history_item.rank?

    h.tag.span(class: 'logged-in-only-background') do
      h.tag.small "#{history_item.rank}-only item", class: 'bold-notice'
    end
  end
end
