# frozen_string_literal: true

class WhatLinksHereTaxts
  def initialize record, record_to_tag_regex_taxt_method
    @record = record
    @taxt_tag = Taxt::RecordToTagRegex.public_send(record_to_tag_regex_taxt_method, record)
  end

  def all
    taxts
  end

  def any?
    any_taxts?
  end

  private

    attr_reader :record, :taxt_tag

    def any_taxts?
      Taxt::TAXTABLES.each do |(model, _table, column)|
        return true if model.where("#{column} REGEXP ?", taxt_tag).exists?
      end
      false
    end

    def taxts
      Taxt::TAXTABLES.each_with_object([]) do |(model, _table, column), wlh_items|
        model.where("#{column} REGEXP ?", taxt_tag).pluck(:id).each do |matched_id|
          wlh_items << WhatLinksHereItem.new(model.table_name, column.to_sym, matched_id)
        end
      end
    end
end
