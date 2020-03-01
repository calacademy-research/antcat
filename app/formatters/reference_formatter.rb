# TODO: Do not cache in database.
# TODO: Cleanup. Can wait until `MissingReference` has been removed.

class ReferenceFormatter
  include ActionView::Context # For `#content_tag`.
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include ActionView::Helpers::SanitizeHelper

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def initialize reference
    @reference = reference
  end

  # Formats the reference as plaintext (with the exception of <i> tags).
  def plain_text
    return generate_plain_text if ENV['NO_REF_CACHE']
    return plain_text_cache.html_safe if plain_text_cache

    References::Cache::Set[reference, generate_plain_text, :plain_text_cache]
  end

  # Formats the reference with HTML, CSS, etc. Click to show expanded.
  def expandable_reference
    return generate_expandable_reference if ENV['NO_REF_CACHE']
    return expandable_reference_cache.html_safe if expandable_reference_cache

    References::Cache::Set[reference, generate_expandable_reference, :expandable_reference_cache]
  end

  # Formats the reference with HTML, CSS, etc.
  def expanded_reference
    return generate_expanded_reference if ENV['NO_REF_CACHE']
    return expanded_reference_cache.html_safe if expanded_reference_cache

    References::Cache::Set[reference, generate_expanded_reference, :expanded_reference_cache]
  end

  private

    attr_reader :reference

    delegate :plain_text_cache, :expandable_reference_cache, :expanded_reference_cache, to: :reference

    # TODO: Very "hmm" case statement.
    def format_citation
      case reference
      when ArticleReference
        "#{reference.journal.name} #{reference.series_volume_issue}:#{reference.pagination}"
      when BookReference
        "#{reference.publisher.display_name}, #{reference.pagination}"
      when NestedReference
        "#{reference.pages_in} #{sanitize ReferenceFormatter.new(reference.nesting_reference).expanded_reference}"
      when MissingReference, UnknownReference
        reference.citation
      else
        raise
      end
    end

    def generate_plain_text
      string = sanitize(reference.author_names_string_with_suffix)
      string << ' '
      string << sanitize(reference.citation_year) << '. '
      string << Unitalicize[reference.decorate.format_title] << ' '
      string << AddPeriodIfNecessary[format_plain_text_citation]
      string
    end

    def generate_expandable_reference
      inner_content = []
      inner_content << generate_expanded_reference
      inner_content << '[online early]' if reference.online_early?
      inner_content << reference.decorate.format_document_links
      content = inner_content.reject(&:blank?).join(' ')

      # TODO: `tabindex: 2` is required or tooltips won't stay open even with `data-click-open="true"`.
      content_tag :span, sanitize(reference.keey),
        data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
        tabindex: "2", title: content.html_safe
    end

    def generate_expanded_reference
      string = author_names_with_links
      string << ' '
      string << sanitize(reference.citation_year) << '. '
      string << link_to(reference.decorate.format_title, reference_path(reference)) << ' '
      string << format_italics(AddPeriodIfNecessary[sanitize(format_citation)])
      string << ' [online early]' if reference.online_early?

      string
    end

    # `format_italics` + `Unitalicize` is to get rid of "*" italics.
    def format_plain_text_citation
      case reference
      when NestedReference
        sanitize "#{reference.pages_in} #{ReferenceFormatter.new(reference.nesting_reference).plain_text}"
      else
        Unitalicize[format_italics(sanitize(format_citation))]
      end
    end

    def author_names_with_links
      string =  reference.author_names.map do |author_name|
                  link_to(sanitize(author_name.name), author_path(author_name.author))
                end.join('; ')

      string << sanitize(" #{reference.author_names_suffix}") if reference.author_names_suffix.present?
      string.html_safe
    end

    def format_italics string
      References::FormatItalics[string]
    end
end
