# frozen_string_literal: true

class WhatLinksHereColumns
  def initialize record, columns_referencing_record
    @record = record
    @columns_referencing_record = columns_referencing_record
  end

  def all
    what_links_here_items
  end

  def any?
    return @_any if defined? @_any
    @_any ||= any_what_links_here_items?
  end

  private

    attr_reader :record, :columns_referencing_record

    def any_what_links_here_items?
      columns_referencing_record.each do |(model, column)|
        return true if model.where(column => record.id).exists?
      end
      false
    end

    def what_links_here_items
      wlh_items = []

      columns_referencing_record.each do |(model, column)|
        model.where(column => record.id).pluck(:id).each do |matched_id|
          wlh_items << wlh_item(model.table_name, column, matched_id)
        end
      end

      wlh_items
    end

    def wlh_item table, field, id
      WhatLinksHereItem.new(table, field, id)
    end
end
