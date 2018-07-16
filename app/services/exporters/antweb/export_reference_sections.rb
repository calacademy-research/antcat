class Exporters::Antweb::ExportReferenceSections
  include ActionView::Helpers::TagHelper
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    return unless taxon.reference_sections.present?

    content_tag :div, class: 'reference_sections' do
      taxon.reference_sections.reduce(''.html_safe) do |content, section|
        content << reference_section(section)
      end
    end
  end

  private

    attr_reader :taxon

    def reference_section section
      content_tag :div, class: 'section' do
        [:title_taxt, :subtitle_taxt, :references_taxt].reduce(''.html_safe) do |content, field|
          if section[field].present?
            content << content_tag(:div, TaxtPresenter[section[field]].to_antweb, class: field)
          end
          content
        end
      end
    end
end
