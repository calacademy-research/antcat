module Types
  class FormatTypeField
    include Service

    def initialize content
      @content = content.try :dup
    end

    def call
      return if content.blank?

      formatted = Types::ExpandInstitutionAbbreviations[content]
      formatted = Types::LinkSpecimenIdentifiers[formatted]
      formatted = TaxtPresenter[formatted].to_html
      formatted.html_safe
    end

    private

      attr :content
  end
end
