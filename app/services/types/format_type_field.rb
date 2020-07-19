# frozen_string_literal: true

module Types
  class FormatTypeField
    include ActionView::Helpers::SanitizeHelper
    include Service

    def initialize content
      @content = content.try(:dup)
    end

    def call
      return if content.blank?

      formatted = sanitize(content).to_str
      formatted = Types::ExpandInstitutionAbbreviations[formatted]
      formatted = Types::LinkSpecimenIdentifiers[formatted]
      formatted = Markdowns::ParseCatalogTags[formatted].html_safe
      formatted.html_safe
    end

    private

      attr_reader :content
  end
end
