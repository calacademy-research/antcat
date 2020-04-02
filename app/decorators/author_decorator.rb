# frozen_string_literal: true

class AuthorDecorator < Draper::Decorator
  delegate :references, :described_taxa

  def published_between
    first_year, most_recent_year =
      references.pluck(Arel.sql('MIN(references.year), MAX(references.year)')).flatten

    return first_year if first_year == most_recent_year
    [first_year, h.ndash, most_recent_year].join
  end

  def taxon_descriptions_between
    first_year, most_recent_year =
      described_taxa.pluck(Arel.sql('MIN(references.year), MAX(references.year)')).flatten
    return unless first_year || most_recent_year

    return first_year if first_year == most_recent_year
    [first_year, h.ndash, most_recent_year].join
  end
end
