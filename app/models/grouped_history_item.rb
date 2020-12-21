# frozen_string_literal: true

class GroupedHistoryItem
  attr_reader :items

  # TODO: This should be delegated to the definiton once they have been extracted into new classes.
  delegate :underscored_type, :groupable?, :group_key, :type, to: :any_item_in_group

  def initialize items
    @items = items
  end

  def taxt
    @_taxt ||= if groupable?
                 any_item_in_group.item_template_to_taxt(grouped_item_taxts: grouped_item_taxts)
               else
                 any_item_in_group.to_taxt
               end
  end

  def grouped?
    !items.one?
  end

  def number_of_items
    items.size
  end

  private

    # HACK: `items.first` is because any item in the same group can be used...
    def any_item_in_group
      @_any_item_in_group ||= items.first
    end

    def grouped_item_taxts
      items.map(&:groupable_item_template_to_taxt).join('; ')
    end
end
