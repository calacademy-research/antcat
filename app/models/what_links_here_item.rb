# frozen_string_literal: true

class WhatLinksHereItem
  attr_accessor :table, :field, :id

  def initialize table, field, id
    @table = table
    @field = field
    @id = id
  end

  def detax
    taxt = if taxt?
             model.find(id).public_send(field)
           elsif table == "history_items"
             model.find(id).to_taxt
           end
    return unless taxt

    Detax[taxt]
  end

  def taxt?
    Taxt::TAXTABLES.any? do |(_taxtable_model, taxtable_table, taxtable_field)|
      table == taxtable_table && field.to_s == taxtable_field
    end
  end

  def owner
    @_owner ||=
      case table
      when "citations"          then Citation.find(id).protonym
      when "history_items"      then HistoryItem.find(id).protonym
      when "protonyms"          then Protonym.find(id)
      when "reference_sections" then ReferenceSection.find(id).taxon
      when "references"         then Reference.find(id)
      when "taxa"               then Taxon.find(id)
      when "type_names"         then TypeName.find(id).protonym
      else                      raise "unknown table #{table}"
      end
  end

  def == other
    self.class == other.class &&
      table == other.table &&
      field == other.field &&
      id == other.id
  end

  private

    def model
      Taxt::TAXTABLES.find do |(_taxtable_model, taxtable_table, _taxtable_field)|
        table == taxtable_table
      end.first
    end
end
