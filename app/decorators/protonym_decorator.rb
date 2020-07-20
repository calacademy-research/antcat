# frozen_string_literal: true

class ProtonymDecorator < Draper::Decorator
  delegate :locality, :uncertain_locality?, :forms, :authorship

  def link_to_protonym
    h.link_to name_with_fossil, h.protonym_path(protonym), class: 'protonym protonym-hover-preview-link'
  end

  def link_to_protonym_with_author_citation
    link_to_protonym << ' ' << protonym.author_citation.html_safe
  end

  def link_to_protonym_with_linked_author_citation
    link_to_protonym <<
      ' ' <<
      h.tag.span(
        h.link_to(protonym.author_citation.html_safe, h.reference_path(protonym.authorship_reference)),
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

    capitalized += ' [uncertain]' if uncertain_locality?
    h.add_period_if_necessary capitalized
  end

  def format_pages_and_forms
    string = authorship.pages.dup
    string << " (#{forms})" if forms
    string
  end
end
