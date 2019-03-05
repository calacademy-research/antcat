module Types
  class FormatTypeField
    include Service
    include ActionView::Helpers::SanitizeHelper

    def initialize content
      @content = strip_tags content.try(:dup)
    end

    def call
      return if content.blank?

      formatted = content
      formatted = Types::ExpandInstitutionAbbreviations[formatted]
      formatted = Types::LinkSpecimenIdentifiers[formatted]
      formatted = Markdowns::ParseAntcatHooks[formatted].html_safe
      formatted.html_safe
    end

    private

      attr :content
  end
end
