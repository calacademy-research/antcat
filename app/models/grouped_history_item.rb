# frozen_string_literal: true

# History items of the same kind shown together as one line on a taxon page.
class GroupedHistoryItem
  attr_reader :items

  # TODO: This should be delegated to the definition once they have been extracted into new classes.
  delegate :underscored_type, :groupable?, :group_key, :type, :relational?, :protonym, to: :any_item_in_group

  def initialize items
    @items = items
  end

  def taxt template_name = :default
    @_taxt_cache ||= {}

    @_taxt_cache[template_name] ||=
      if groupable?
        any_item_in_group.item_template_to_taxt(template_name, grouped_item_taxts: grouped_item_taxts)
      else
        any_item_in_group.to_taxt template_name
      end
  end

  def grouped?
    !items.one?
  end

  def number_of_items
    items.size
  end

  # For the editors' "Show/hide grouped" toggle. `group_key` is an array for most types
  # (e.g. `["JuniorSynonymOf", "object_protonym_id", 156572]`) but just the type name for
  # types grouped by type alone (StatusAsSpecies, FormDescriptions).
  def toggler_key
    "grouped-#{Array(group_key).join('_')}"
  end

  def params_for_add_another_of_same_type
    any_item_in_group.decorate.params_for_add_another_of_same_type
  end

  private

    # HACK: `items.first` is because any item in the same group can be used...
    def any_item_in_group
      @_any_item_in_group ||= items.first
    end

    def grouped_item_taxts
      items.map(&:groupable_template_to_taxt).join('; ')
    end
end
