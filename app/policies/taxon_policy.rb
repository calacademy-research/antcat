# frozen_string_literal: true

class TaxonPolicy
  attr_private_initialize :taxon

  def show_create_combination_button?
    taxon.type.in?(Rank::SHOW_CREATE_COMBINATION_BUTTON_TYPES)
  end

  def allow_create_combination?
    CreateCombinationPolicy.new(taxon).allowed?
  end

  def show_create_combination_help_button?
    taxon.type.in?(Rank::SHOW_CREATE_COMBINATION_HELP_BUTTON_TYPES)
  end

  def allow_create_obsolete_combination?
    taxon.type.in?(Rank::ALLOW_CREATE_OBSOLETE_COMBINATION_TYPES) && taxon.valid_status? && taxon.genus.present?
  end

  def allow_force_change_parent?
    taxon.type.in?(Rank::ALLOW_FORCE_CHANGE_PARENT_TYPES)
  end
end
