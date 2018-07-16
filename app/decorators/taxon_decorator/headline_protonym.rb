class TaxonDecorator::HeadlineProtonym
  include ActionView::Helpers
  include ActionView::Context
  include Service
  include ApplicationHelper

  def initialize taxon, for_antweb: false
    @taxon = taxon
    @for_antweb = for_antweb
  end

  def call
    headline_protonym
  end

  private

    def headline_protonym
      protonym = @taxon.protonym
      return ''.html_safe unless protonym
      string = protonym_name protonym
      string << ' ' << authorship(protonym.authorship)
      string << locality(protonym.locality)
      add_period_if_necessary(string || '')
    end

    def protonym_name protonym
      content_tag :b do
        content_tag :span do
          protonym.name.protonym_with_fossil_html protonym.fossil
        end
      end
    end

    def authorship authorship
      return '' unless authorship.try :reference
      string = link_to_reference authorship.reference
      string << ": #{authorship.pages}" if authorship.pages.present?
      string << " (#{authorship.forms})" if authorship.forms.present?

      if authorship.notes_taxt.present?
        if for_antweb?
          string << ' ' << TaxtPresenter[authorship.notes_taxt].to_antweb
        else
          string << ' ' << TaxtPresenter[authorship.notes_taxt].to_html
        end
      end

      content_tag :span, string
    end

    def locality locality
      return '' unless locality.present?
      locality = locality.upcase.gsub(/\(.+?\)/, &:titlecase)
      add_period_if_necessary ' ' + locality
    end

    # TODO refactor more. Formerly based on `$use_ant_web_formatter`.
    def for_antweb?
      @for_antweb
    end

    # TODO rename.
    def link_to_reference reference
      if for_antweb?
        Exporters::Antweb::InlineCitation[reference]
      else
        reference.decorate.inline_citation
      end
    end
end
