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

      # Expansions insert HTML, so they must not run inside attribute values.
      formatted = Markdowns::ExpandOutsideAttributes.call(sanitize(content).to_str) do |masked|
        masked = Types::ExpandInstitutionAbbreviations[masked]
        masked = Types::LinkSpecimenIdentifiers[masked]
        Markdowns::ParseCatalogTags[masked]
      end
      formatted.html_safe
    end

    private

      attr_reader :content
  end
end
