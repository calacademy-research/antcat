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

  # Formats the reference with HTML, CSS, etc.
  def expandable_reference
    return generate_expandable_reference if ENV['NO_REF_CACHE']

    cached = reference.expandable_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expandable_reference, :expandable_reference_cache
  end

  def linked_keey
    helpers.link_to reference.keey, helpers.reference_path(reference)
  end

  def format_title
    format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
  end

  private

    def generate_plain_text
      string = make_html_safe(reference.author_names_string_with_suffix)
      string << ' ' unless string.empty?
      string << make_html_safe(reference.citation_year) << '. '
      string << format_title << ' '
      string << format_italics(helpers.add_period_if_necessary(format_citation))
      string
    end

    def generate_expandable_reference
      helpers.content_tag :span, class: "expandable-reference" do
        link = helpers.link_to reference.keey, '#',
          title: helpers.unitalicize(plain_text), class: "expandable-reference-key"

        content = link
        content << helpers.content_tag(:span, class: "expandable-reference-content") do
          inner_content = []
          inner_content << expandable_reference_text
          inner_content << format_reference_document_link
          inner_content << small_reference_link_button
          inner_content.reject(&:blank?).join(' ').html_safe
        end
      end
    end

    def expandable_reference_text
      helpers.content_tag :span, plain_text, class: "expandable-reference-text"
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

    def format_italics string
      return unless string
      raise "Can't call format_italics on an unsafe string" unless string.html_safe?
      string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
      string.html_safe
    end

    def doi_link
      return unless reference.doi?
      helpers.link_to reference.doi, ("https://doi.org/" + doi)
    end

    def pdf_link
      return unless reference.downloadable?
      helpers.link_to 'PDF', reference.url
    end
end
