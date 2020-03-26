# frozen_string_literal: true

class JournalDecorator < Draper::Decorator
  delegate :references

  def publications_between
    first_year = references.minimum(:year)
    most_recent_year = references.maximum(:year)

    return first_year if first_year == most_recent_year
    "#{first_year}#{helpers.dash}#{most_recent_year}".html_safe
  end
end
