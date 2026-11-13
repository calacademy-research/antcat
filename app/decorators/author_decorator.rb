# frozen_string_literal: true

# Formats an author's page: the years of the author's references and of the taxa they described.
class AuthorDecorator < Draper::Decorator
  delegate :references, :described_taxa

  def published_between
    min_year, max_year = references.pluck(Arel.sql('MIN(references.year), MAX(references.year)')).flatten

    [min_year, max_year].uniq.join(h.ndash).presence
  end

  def taxon_descriptions_between
    min_year, max_year = described_taxa.pluck(Arel.sql('MIN(references.year), MAX(references.year)')).flatten

    [min_year, max_year].uniq.join(h.ndash).presence
  end
end
