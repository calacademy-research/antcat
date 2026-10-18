# frozen_string_literal: true

# What Links Here for visitors (not signed in): leaves out taxt items that link to the record only
# from inside hidden notes (`{hiddennote ...}`), since visitors cannot see those notes.
# One query per taxt column, only for rows that contain a hidden note.
class WhatLinksHereVisibleItems
  include Service

  # `record_to_tag_regex_method` is the `Taxt::RecordToTagRegex` method for the record (:taxon, ...).
  def initialize what_links_here_items, record, record_to_tag_regex_method
    @what_links_here_items = what_links_here_items
    @tag_regex = Regexp.new(Taxt::RecordToTagRegex.public_send(record_to_tag_regex_method, record))
  end

  def call
    hidden = linked_only_inside_hidden_notes
    return what_links_here_items if hidden.empty?

    what_links_here_items.reject { |item| hidden.include?([item.table, item.field.to_s, item.id]) }
  end

  private

    attr_reader :what_links_here_items, :tag_regex

    def linked_only_inside_hidden_notes
      taxt_items = what_links_here_items.select(&:taxt?)

      taxt_items.group_by { |item| [item.table, item.field.to_s] }.each_with_object(Set.new) do |((table, field), items), hidden|
        model = Taxt::TAXTABLES.find { |(_model, taxtable_table, _field)| taxtable_table == table }.first

        model.where(id: items.map(&:id)).where("#{field} LIKE ?", VisibleTaxtLikeSearch::HIDDENNOTE_LIKE).
          pluck(:id, field).each do |(id, taxt)|
            hidden << [table, field, id] unless Taxt.remove_hidden_notes(taxt).match?(tag_regex)
          end
      end
    end
end
