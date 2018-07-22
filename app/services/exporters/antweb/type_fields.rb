class Exporters::Antweb::TypeFields
  include ApplicationHelper
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    formatted_type_fields.reject(&:blank?).join(' ').html_safe
  end

  private

    attr_reader :taxon

    def formatted_type_fields
      [published_type_information, additional_type_information, type_notes]
    end

    def published_type_information
      return if taxon.published_type_information.blank?
      add_period_if_necessary "Primary type information: #{detax(taxon.published_type_information)}"
    end

    def additional_type_information
      return if taxon.additional_type_information.blank?
      add_period_if_necessary "Secondary type information: #{detax(taxon.additional_type_information)}"
    end

    def type_notes
      return if taxon.type_notes.blank?
      add_period_if_necessary "Type notes: #{detax(taxon.type_notes)}"
    end

    def detax content
      TaxtPresenter[content].to_antweb
    end
end
