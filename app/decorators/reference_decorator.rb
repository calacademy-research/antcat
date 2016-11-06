# Many methods here are prefixed "format_" to avoid clashing with the objects's
# methods, or because they were named so in the old `ReferenceFormatter`
# Slightly ugly but I'm not sure what to do now.

class ReferenceDecorator < ApplicationDecorator
  include ERB::Util # for the `h` method
  delegate_all

  def key
    format_author_last_names
  end

  def created_at
    format_timestamp reference.created_at
  end

  def updated_at
    format_timestamp reference.updated_at
  end

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

  def format_authorship_html
    helpers.content_tag(:span, title: format) do
      format_author_last_names
    end
  end

  def format_review_state
    review_state = reference.review_state

    case review_state
    when 'reviewing' then 'Being reviewed'
    when 'none', nil then ''
    else                  review_state.capitalize
    end
  end

  def format
    cached = reference.cached :formatted_cache
    return cached.html_safe if cached

    generated = format!
    reference.set_cache generated, :formatted_cache
    generated
  end

  def format!
    string = format_author_names.dup
    string << ' ' unless string.empty?
    string << format_year << '. '
    string << format_title << ' '
    string << format_citation
    string << " [#{format_date(reference.date)}]" if reference.date?
    string
  end

  # TODO it may be safe to remove `options` now that the AntWeb exception
  # has been extracted into `#format_inline_citation_without_expansion`.
  def format_inline_citation options = {}
    cached = reference.cached :inline_citation_cache
    return cached.html_safe if cached

    generated = format_inline_citation! options
    reference.set_cache generated, :inline_citation_cache
    generated
  end

  def format_inline_citation! options = {}
    to_link options
  end

  def format_inline_citation_without_links
    format_author_last_names
  end

  # Only used for the AntWeb export.
  def format_inline_citation_without_expansion
    format_inline_citation! expansion: false
  end

  # TODO see LinkHelper#link.
  def goto_reference_link target: '_blank'
    helpers.link reference.id, helpers.reference_path(reference),
      class: :goto_reference_link, target: target
  end

  def to_link expansion: true
    reference_key_string = format_author_last_names
    reference_string = format
    if expansion
      to_link_with_expansion reference_key_string, reference_string
    else
      to_link_without_expansion reference_key_string, reference_string
    end
  end

  private
    def format_timestamp timestamp
      timestamp.strftime '%Y-%m-%d'
    end

    def make_html_safe string
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
      string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
      string.html_safe
    end

    def format_date input # TODO? store denormalized value in the database
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

    # TODO see LinkHelper#link.
    def doi_link
      return unless reference.doi.present?
      helpers.link reference.doi, create_link_from_doi(reference.doi),
        class: 'document_link', target: '_blank'
    end

    # TODO see LinkHelper#link.
    def pdf_link
      return unless reference.downloadable?
      helpers.link 'PDF', reference.url, class: 'document_link', target: '_blank'
    end

    # transform "10.11646/zootaxa.4029.1.1" --> "http://dx.doi.org/10.11646/zootaxa.4029.1.1"
    def create_link_from_doi doi
      "http://dx.doi.org/" + doi
    end

    # TODO see LinkHelper#link.
    def to_link_with_expansion reference_key_string, reference_string
      helpers.content_tag :span, class: :reference_key_and_expansion do
        content = helpers.link reference_key_string, '#',
                       title: make_to_link_title(reference_string),
                       class: :reference_key

        content << helpers.content_tag(:span, class: :reference_key_expansion) do
          inner_content = []
          inner_content << reference_key_expansion_text(reference_string, reference_key_string)
          inner_content << format_reference_document_link
          inner_content << goto_reference_link
          inner_content.reject(&:blank?).join(' ').html_safe
        end
      end
    end

    # TODO see LinkHelper#link.
    def to_link_without_expansion reference_key_string, reference_string
      content = []
      content << helpers.link(reference_key_string,
                      "http://antcat.org/references/#{reference.id}",
                      title: make_to_link_title(reference_string),
                      target: '_blank')
      content << format_reference_document_link
      content.reject(&:blank?).join(' ').html_safe
    end

    def make_to_link_title string
      helpers.unitalicize string
    end

    def reference_key_expansion_text reference_string, reference_key_string
      helpers.content_tag :span, reference_string,
        class: :reference_key_expansion_text,
        title: reference_key_string
    end

    def format_author_last_names
      return '' unless reference.id

      names = reference.author_names.map &:last_name
      case names.size
      when 0
        '[no authors]'
      when 1
        "#{names.first}"
      when 2
        "#{names.first} & #{names.second}"
      else
        string = names[0..-2].join ', '
        string << " & " << names[-1]
      end << ', ' << reference.short_citation_year
    end

    def format_author_names
      make_html_safe reference.author_names_string
    end

    def format_year
      make_html_safe reference.citation_year if reference.citation_year?
    end

    def format_title
      format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
    end
end
