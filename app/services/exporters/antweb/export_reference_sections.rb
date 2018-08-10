class Exporters::Antweb::ExportReferenceSections
  include ActionView::Helpers::TagHelper
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    return if taxon.reference_sections.blank?

    content_tag :div do
      taxon.reference_sections.reduce(''.html_safe) do |content, section|
        content << reference_section(section)
      end
    end
  end

  private

    attr_reader :taxon

    def reference_section section
      content_tag :div do
        [:title_taxt, :subtitle_taxt, :references_taxt].each_with_object(''.html_safe) do |field, content|
          if section[field].present?
            content << content_tag(:div, TaxtPresenter[section[field]].to_antweb)
          end
        end
      end
    end
end
