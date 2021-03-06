# frozen_string_literal: true

class ProtonymDecorator < Draper::Decorator
  delegate :locality, :forms, :authorship

  def link_to_protonym
    link_to_protonym_with_label name_with_fossil
  end

  def link_to_protonym_with_author_citation
    link_to_protonym << ' ' << protonym.author_citation.html_safe
  end

  def link_to_protonym_epithet
    link_to_protonym_with_label(protonym.name.epithet_html)
  end

  def link_to_protonym_with_linked_author_citation
    authorship_reference = protonym.authorship_reference

    link_to_protonym <<
      ' ' <<
      h.tag.span(
        h.link_to(
          protonym.author_citation.html_safe,
          h.reference_path(authorship_reference),
          'v-hover-reference' => authorship_reference.id
        ),
        class: 'discret-author-citation'
      )
  end

  def name_with_fossil
    protonym.name.name_with_fossil_html protonym.fossil?
  end

  def format_locality
    return unless locality

    first_parenthesis = locality.index("(")
    capitalized =
      if first_parenthesis
        before = locality[0...first_parenthesis]
        rest = locality[first_parenthesis..]
        before.mb_chars.upcase + rest
      else
        locality.mb_chars.upcase
      end

    h.add_period_if_necessary capitalized
  end

  def format_pages_and_forms
    string = authorship.pages.dup
    string << " (#{forms})" if forms
    string
  end

  private

    def link_to_protonym_with_label label
      h.link_to label, h.protonym_path(protonym),
        'v-hover-protonym' => protonym.id,
        class: 'protonym'
    end
end
