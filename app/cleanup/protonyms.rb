# frozen_string_literal: true

module Protonyms
  SEMI_NORMALIZED_NOTES_TAXTS = [
    /^ ?\[as subgenus of \{tax|taxac \d+\}\]$/,
    /^ ?\[as "section" of \{tax|taxac \d+\}\]$/,
    /^ ?\[as "group" of \{tax|taxac \d+\}\]$/,
    /^ ?\[as "branch" of \{tax|taxac \d+\}\]$/
  ]

  module_function

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  def all_taxa_above_genus_and_of_unique_different_ranks? taxa
    ranks = taxa.pluck(:type)
    (ranks - Rank::ABOVE_GENUS).empty? && ranks.uniq.size == ranks.size
  end

  def all_statuses_same? taxa
    taxa.pluck(:status).uniq.size == 1
  end

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  def taxa_genus_and_subgenus_pair? taxa
    taxa.pluck(:type).sort == %w[Genus Subgenus]
  end

  def semi_normalized_notes_taxt? notes_taxt
    SEMI_NORMALIZED_NOTES_TAXTS.any? { |re| re =~ notes_taxt }
  end
end
