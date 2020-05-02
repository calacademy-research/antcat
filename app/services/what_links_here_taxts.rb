# frozen_string_literal: true

class WhatLinksHereTaxts
  def initialize record, taxt_tag_method
    @record = record
    @taxt_tag = Taxt.public_send(taxt_tag_method, record)
  end

  def all
    what_links_here_items
  end

  def any?
    return @_any if defined? @_any
    @_any ||= any_what_links_here_items?
  end

  private

    attr_reader :record, :taxt_tag

    def any_what_links_here_items?
      Taxt::TAXTABLES.each do |(model, _table, field)|
        return true if model.where("#{field} REGEXP ?", taxt_tag).exists?
      end
      false
    end

    def what_links_here_items
      wlh_items = []

      Taxt::TAXTABLES.each do |(model, _table, field)|
        model.where("#{field} REGEXP ?", taxt_tag).pluck(:id).each do |matched_id|
          wlh_items << wlh_item(model.table_name, field.to_sym, matched_id)
        end
      end

      wlh_items
    end

    def wlh_item table, field, id
      WhatLinksHereItem.new(table, field, id)
    end
end
