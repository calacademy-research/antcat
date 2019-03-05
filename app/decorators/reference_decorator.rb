# TODO: do not cache in database.
# TODO: refactor.

class ReferenceDecorator < ApplicationDecorator
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util # For the `h` method.

  delegate_all

  def public_notes
    format_italics sanitize reference.public_notes
  end

  def editor_notes
    format_italics sanitize reference.editor_notes
  end

  def taxonomic_notes
    format_italics sanitize reference.taxonomic_notes
  end

  # TODO store denormalized value in the database?
  def format_date
    reference_date = reference.date
    return unless reference_date
    return reference_date if reference_date.size < 4

    match = reference_date.match /(.*?)(\d{4,8})(.*)/
    prefix = match[1]
    digits = match[2]
    suffix = match[3]

    year  = digits[0...4]
    month = digits[4...6]
    day   = digits[6...8]

    date = year
    date << '-' + month if month.present?
    date << '-' + day if day.present?

    prefix + date + suffix
  end

  # TODO rename as it also links DOIs, not just reference documents.
  def format_reference_document_link
    [doi_link, pdf_link].reject(&:blank?).join(' ').html_safe
  end

  def format_review_state
    review_state = reference.review_state

    case review_state
    when 'reviewing' then 'Being reviewed'
    when 'none', nil then ''
    else                  review_state.capitalize
    end
  end

  # Formats the reference as plaintext (with the exception of <i> tags).
  def plain_text
    return generate_plain_text if ENV['NO_REF_CACHE']

    cached = reference.plain_text_cache
    return cached.html_safe if cached

    reference.set_cache generate_plain_text, :plain_text_cache
  end

  # Formats the reference with HTML, CSS, etc. Click to show expanded.
  def expandable_reference
    return generate_expandable_reference if ENV['NO_REF_CACHE']

    cached = reference.expandable_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expandable_reference, :expandable_reference_cache
  end

  # Formats the reference with HTML, CSS, etc.
  def expanded_reference
    return generate_expanded_reference if ENV['NO_REF_CACHE']

    cached = reference.expanded_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expanded_reference, :expanded_reference_cache
  end

  def format_plain_text_title
    format_italics helpers.add_period_if_necessary sanitize(reference.title)
  end

  private

    def generate_plain_text
      string = sanitize(reference.author_names_string_with_suffix)
      string << ' ' unless string.empty?
      string << sanitize(reference.citation_year) << '. '
      string << helpers.unitalicize(format_plain_text_title) << ' '
      string << helpers.add_period_if_necessary(format_plain_text_citation)
      string
    end

    def generate_expandable_reference
      inner_content = []
      inner_content << generate_expanded_reference
      inner_content << format_reference_document_link
      content = inner_content.reject(&:blank?).join(' ')

      # TODO: `tabindex: 2` is required or tooltips won't stay open even with `data-click-open="true"`.
      helpers.content_tag :span, sanitize(reference.keey),
        data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
        tabindex: "2", title: content.html_safe
    end

    def generate_expanded_reference
      string = sanitize author_names_with_links
      string << ' ' unless string.empty?
      string << sanitize(reference.citation_year) << '. '
      string << format_title_with_link << ' '
      string << format_italics(helpers.add_period_if_necessary(format_citation))

      string
    end

    # Override in subclasses as necessary.
    def format_plain_text_citation
      # `format_citation` + `unitalicize` is go get rid of "*" italics.
      helpers.unitalicize format_italics(sanitize(format_citation))
    end

    def author_names_with_links
      string =  reference.author_names.map do |author_name|
                  helpers.link_to(sanitize(author_name.name), author_name.author)
                end.join('; ')

      string << sanitize(" #{author_names_suffix}") if author_names_suffix.present?
      string
    end

    def format_title_with_link
      helpers.link_to format_plain_text_title, helpers.reference_path(reference)
    end

    def format_italics string
      return unless string
      raise "Can't call format_italics on an unsafe string" unless string.html_safe?
      string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
      string.html_safe
    end

    def doi_link
      return unless reference.doi?
      helpers.external_link_to reference.doi, ("https://doi.org/" + doi)
    end

    def pdf_link
      return unless reference.downloadable?
      helpers.pdf_link_to 'PDF', reference.url
    end
end
