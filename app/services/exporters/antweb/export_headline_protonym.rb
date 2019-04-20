class Exporters::Antweb::ExportHeadlineProtonym
  include ActionView::Helpers
  include ActionView::Context
  include Service
  include ApplicationHelper

  def initialize protonym
    @protonym = protonym
  end

  def call
    add_period_if_necessary headline_protonym
  end

  private

    attr_reader :protonym

    def headline_protonym
      [
        protonym_name,
        authorship(protonym.authorship),
        protonym.decorate.format_locality
      ].compact.join(" ").html_safe
    end

    def protonym_name
      content_tag :b do
        protonym.decorate.format_name
      end
    end

    def authorship authorship
      string = link_to_reference authorship.reference
      string << protonym.decorate.format_pages_and_forms

      if authorship.notes_taxt.present?
        string << ' ' << TaxtPresenter[authorship.notes_taxt].to_antweb
      end

      string
    end

    def link_to_reference reference
      Exporters::Antweb::InlineCitation[reference]
    end
end
