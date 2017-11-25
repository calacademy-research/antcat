# TODO consider renaming the db fields once the code is more stable.

class ReferenceDecorator < ApplicationDecorator
  include ERB::Util # For the `h` method.

  delegate_all

  def public_notes
    format_italics h reference.public_notes
  end

  def editor_notes
    format_italics h reference.editor_notes
  end

  def taxonomic_notes
    format_italics h reference.taxonomic_notes
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
  # DB column: `references.formatted_cache`.
  def formatted
    cached = reference.formatted_cache
    return cached.html_safe if cached

    reference.set_cache generate_formatted, :formatted_cache
  end

  # Formats the reference with HTML, CSS, etc.
  # DB column: `references.inline_citation_cache`.
  def inline_citation
    cached = reference.inline_citation_cache
    return cached.html_safe if cached

    reference.set_cache generate_inline_citation, :inline_citation_cache
  end

  def linked_keey
    helpers.link_to reference.keey, helpers.reference_path(reference)
  end

  def format_title
    format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
  end

  private
    def generate_formatted
      string = make_html_safe(reference.author_names_string.dup)
      string << ' ' unless string.empty?
      string << make_html_safe(reference.citation_year) << '. '
      string << format_title << ' '
      string << format_italics(helpers.add_period_if_necessary(format_citation))
      string << " [#{format_date(reference.date)}]" if reference.date?
      string
    end

    def generate_inline_citation
      helpers.content_tag :span, class: "reference_keey_and_expansion" do
        link = helpers.link_to reference.keey, '#',
          title: helpers.unitalicize(formatted), class: "reference_keey"

        content = link
        content << helpers.content_tag(:span, class: "reference_keey_expansion") do
          inner_content = []
          inner_content << inline_citation_reference_keey_expansion_text
          inner_content << format_reference_document_link
          inner_content << small_reference_link_button
          inner_content.reject(&:blank?).join(' ').html_safe
        end
      end
    end

    def inline_citation_reference_keey_expansion_text
      helpers.content_tag :span, formatted,
        class: "reference_keey_expansion_text", title: reference.keey
    end

    def small_reference_link_button
      # TODO replace `reference.id` with "Show" (requires invalidating all references).
      helpers.link_to reference.id, helpers.reference_path(reference),
        class: "btn-normal btn-tiny"
    end

    # TODO try to move somewhere more general, even if it's only used here.
    # TODO see if there's Rails version of this.
    def make_html_safe string
      return ''.html_safe if string.blank?

      string = string.dup
      quote_code = 'xdjvs4'
      begin_italics_code = '2rjsd4'
      end_italics_code = '1rjsd4'
      string.gsub! '<i>', begin_italics_code
      string.gsub! '</i>', end_italics_code
      string.gsub! '"', quote_code
      string = h string
      string.gsub! quote_code, '"'
      string.gsub! end_italics_code, '</i>'
      string.gsub! begin_italics_code, '<i>'
      string.html_safe
    end

    # TODO try to move somewhere more general, even if it's only used here.
    def format_italics string
      return unless string
      raise "Can't call format_italics on an unsafe string" unless string.html_safe?
      string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
      string.html_safe
    end

    # TODO rename?
    # TODO store denormalized value in the database?
    def format_date input
      return input if input.size < 4

      match = input.match /(.*?)(\d{4,8})(.*)/
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

    def doi_link
      return unless reference.doi?
      helpers.link_to reference.doi, ("http://dx.doi.org/" + doi)
    end

    def pdf_link
      return unless reference.downloadable?
      helpers.link_to 'PDF', reference.url
    end
end
