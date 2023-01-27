# frozen_string_literal: true

class JournalDecorator < Draper::Decorator
  delegate :references

  def publications_between
    min_year, max_year = references.pluck(Arel.sql('MIN(references.year), MAX(references.year)')).flatten

    [min_year, max_year].uniq.join(h.ndash).presence
  end
end
