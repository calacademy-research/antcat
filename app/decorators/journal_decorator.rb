# frozen_string_literal: true

class JournalDecorator < Draper::Decorator
  delegate :references

  def publications_between
    first_year = references.minimum(:year)
    most_recent_year = references.maximum(:year)

    return first_year if first_year == most_recent_year
    [first_year, h.ndash, most_recent_year].join
  end
end
