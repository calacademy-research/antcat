# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
TableRef = Struct.new(:table, :field, :id) do
  def detax
    return "&ndash;".html_safe unless taxt?
    Detax[model.find(id).public_send(field)]
  end

  def taxt?
    Taxt::TAXTABLES.any? do |(_taxtable_model, taxtable_table, taxtable_field)|
      table == taxtable_table && field.to_s == taxtable_field
    end
  end

  def owner
    @owner ||=
      case table
      when "citations"           then Citation.find(id).protonym
      when "protonyms"           then Protonym.find(id)
      when "reference_sections"  then ReferenceSection.find(id).taxon
      when "references"          then Reference.find(id)
      when "taxon_history_items" then TaxonHistoryItem.find(id).taxon
      when "taxa"                then Taxon.find(id)
      else                       raise "unknown table #{table}"
      end
  end

  private

    def model
      Taxt::TAXTABLES.find do |(_taxtable_model, taxtable_table, _taxtable_field)|
        table == taxtable_table
      end.first
    end
end
# rubocop:enable Metrics/BlockLength
