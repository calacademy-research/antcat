# TODO something. Less methods. Method names.
# TODO investigate using views.
# TODO use less decorators in general.

=begin
Notes

DRY these:
Reference#author_names_string
Reference#author_names_string_cache
Reference#principal_author_last_name
Reference#principal_author_last_name_cache
Reference#reference_author_names
Reference#author_names_suffix
Reference#author_names
ReferenceDecorator#keey
ReferenceDecorator#format_authorship_html
Citation#authorship_string
Citation#authorship_html_string
Citation#author_last_names_string
Citation#author_names_string

Similar but a slightly different thing, sometimes, probably:
Taxon#authorship_string x 2

In Taxon:
`delegate :authorship_html_string, :author_last_names_string, :year, to: :protonym`

In Protonym:
`delegate :authorship_string, :authorship_html_string, :author_last_names_string, :year,
  to: :authorship` + `belongs_to :authorship, class_name: 'Citation'`

So, we're back in Citation which means we're sometimes back in
Reference and sometimes in ReferenceDecorator.

---------------

Examples from `r = Reference.first`

r.author_names # AuthorName CollectionProxy

r.key_cache # "Abdul-Rassoul, Dawah & Othman, 1978"

r.decorate.keey # "Abdul-Rassoul, Dawah & Othman, 1978"

r.author_names_string_cache # "Abdul-Rassoul, M. S.; Dawah, H. A.; Othman, N. Y."

r.author_names_string # same as `r.author_names_string_cache`

r.authors # Array of `Author`s

r.reference_author_names # ReferenceAuthorName CollectionProxy

r.principal_author_last_name # "Abdul-Rassoul"; possibly only used for sorting.

r.author # same as `r.principal_author_last_name`

r.author_names_suffix # nil; probably non-nil for things like ", Jr."

=end

class ReferenceDecorator < ApplicationDecorator
  include ERB::Util # for the `h` method
  delegate_all

  def key
    raise "use 'keey' (not a joke)"
  end

  # New! "THE KEEY" -- Stupid Name Because Useful(tm).
  #
  # TODO trying to consolidate all "FALNs" here.
  #
  # Looks like: "Abdul-Rassoul, Dawah & Othman, 1978"
  #
  # "key" is impossible to grep for, and a word with too many meanings.
  # Variations of "last author names" or "ref_key" are doomed to fail.
  # So, "keey". Obviously, do not show this spelling to users or use
  # it in filesnames or the database.
  #
  # See also `references.key_cache`.
  #
  # Note 1: this the new name of `#format_author_last_names` (the original "FALNs").
  # Note 2: `references.author_names_string_cache` may also be useful.
  # Note 3: very similar to `Citation#author_names_string` (which doesn't include year).
  def keey
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

  # TODO inline.
  def public_notes
    format_italics h reference.public_notes
  end

  # TODO inline.
  def editor_notes
    format_italics h reference.editor_notes
  end

  # TODO inline.
  def taxonomic_notes
    format_italics h reference.taxonomic_notes
  end

  # TODO rename as it also links DOIs, not just reference documents.
  def format_reference_document_link
    [doi_link, pdf_link].reject(&:blank?).join(' ').html_safe
  end

  # TODO only called in `Citation#authorship_html_string`.
  def format_authorship_html
    helpers.content_tag(:span, title: formatted) do
      keey
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

  # A.k.a. "FORMAT IT AS TEXT" -- Cached version!
  # Formats the reference as plaintext (with the exception of <i> tags).
  #
  # DB column: `references.formatted_cache`.
  def formatted
    cached = reference.formatted_cache
    return cached.html_safe if cached

    generated = generate_formatted
    reference.set_cache generated, :formatted_cache
    generated
  end

  # A.k.a. "FORMATTED WITH HTML" -- Cached version!
  # Formats the reference with HTML, CSS, etc.
  #
  # DB column: `references.inline_citation_cache`.
  def inline_citation
    cached = reference.inline_citation_cache
    return cached.html_safe if cached

    generated = generate_inline_citation
    reference.set_cache generated, :inline_citation_cache
    generated
  end

  # Note: Only used for the AntWeb export. Never cached.
  # TODO see LinkHelper#link.
  def antweb_version_of_inline_citation
    content = []
    content << helpers.link(keey,
                    "http://antcat.org/references/#{reference.id}",
                    title: make_to_link_title(formatted),
                    target: '_blank')
    content << format_reference_document_link
    content.reject(&:blank?).join(' ').html_safe
  end

  # TODO see LinkHelper#link.
  # TODO maybe remove? "target: '_blank'" sucks and the CSS class is not used.
  def goto_reference_link target: '_blank'
    helpers.link reference.id, helpers.reference_path(reference),
      class: "goto_reference_link", target: target
  end

  private
    # A.k.a. "FORMAT IT AS TEXT" -- Generate-it version!
    def generate_formatted
      string = make_html_safe(reference.author_names_string.dup)
      string << ' ' unless string.empty?
      string << make_html_safe(reference.citation_year) << '. '
      string << format_title << ' '
      string << format_citation
      string << " [#{format_date(reference.date)}]" if reference.date?
      string
    end

    # TODO see LinkHelper#link.
    # A.k.a. "FORMATTED WITH HTML" -- Generate-it version!
    def generate_inline_citation
      helpers.content_tag :span, class: "reference_keey_and_expansion" do
        content = helpers.link keey, '#',
                       title: make_to_link_title(formatted),
                       class: "reference_keey"

        content << helpers.content_tag(:span, class: "reference_keey_expansion") do
          inner_content = []
          inner_content << inline_citation_reference_keey_expansion_text
          inner_content << format_reference_document_link
          inner_content << goto_reference_link
          inner_content.reject(&:blank?).join(' ').html_safe
        end
      end
    end

    def inline_citation_reference_keey_expansion_text
      helpers.content_tag :span, formatted,
        class: "reference_keey_expansion_text",
        title: keey
    end

    # TODO try to move somewhere more general, even if it's only used here.
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

    # TODO try to move somewhere more general, even if it's only used here.
    def format_italics string
      return unless string
      raise "Can't call format_italics on an unsafe string" unless string.html_safe?
      string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
      string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
      string.html_safe
    end

    # TODO rename?
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
      helpers.link reference.doi, ("http://dx.doi.org/" + doi),
        class: 'document_link', target: '_blank'
    end

    # TODO see LinkHelper#link.
    def pdf_link
      return unless reference.downloadable?
      helpers.link 'PDF', reference.url, class: 'document_link', target: '_blank'
    end

    def make_to_link_title string
      helpers.unitalicize string
    end

    # TODO try to remove in favor of direct attribute access.
    def format_title
      format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
    end
end
