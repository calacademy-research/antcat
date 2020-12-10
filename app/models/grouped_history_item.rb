# frozen_string_literal: true

class GroupedHistoryItem
  attr_reader :items

  def initialize items
    @items = items
  end

  def taxt
    @_taxt ||= any_item_in_group.section_to_taxt(item_taxts)
  end

  def type
    @_type ||= any_item_in_group.type
  end

  private

    # HACK: `items.first` is because any item in the same group can be used...
    def any_item_in_group
      @_any_item_in_group ||= items.first
    end

    def item_taxts
      items.map(&:groupable_item_taxt).join('; ')
    end
end
