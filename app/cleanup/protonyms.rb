# frozen_string_literal: true

# :nocov:
module Protonyms
  module_function

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  def all_taxa_above_genus_and_of_unique_different_ranks? taxa
    ranks = taxa.pluck(:type)
    (ranks - Rank::TYPES_ABOVE_GENUS).empty? && ranks.uniq.size == ranks.size
  end

  def all_statuses_same? taxa
    taxa.pluck(:status).uniq.size == 1
  end

  # TODO: This does not belong anywhere, but it's a step towards moving data to the protonym.
  def taxa_genus_and_subgenus_pair? taxa
    taxa.pluck(:type).sort == %w[Genus Subgenus]
  end
end
# :nocov:
