# frozen_string_literal: true

class WhatLinksHereColumns
  def initialize record, columns_referencing_record
    @record = record
    @columns_referencing_record = columns_referencing_record
  end

  def all
    columns
  end

  def any?
    any_columns?
  end

  private

    attr_reader :record, :columns_referencing_record

    def any_columns?
      columns_referencing_record.each do |(model, column)|
        return true if model.where(column => record.id).exists?
      end
      false
    end

    def columns
      wlh_items = []

      columns_referencing_record.each do |(model, column)|
        model.where(column => record.id).pluck(:id).each do |matched_id|
          wlh_items << WhatLinksHereItem.new(model.table_name, column, matched_id)
        end
      end

      wlh_items
    end
end
