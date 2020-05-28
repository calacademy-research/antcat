# frozen_string_literal: true

class ProtonymDecorator < Draper::Decorator
  delegate :locality, :uncertain_locality?, :authorship, :name, :fossil?

  def link_to_protonym
    h.link_to name_with_fossil, h.protonym_path(protonym), class: 'protonym'
  end

  # TODO: This does not seem to be `included` when used in `DatabaseScripts::ProtonymsWithNotesTaxt`.
  def name_with_fossil
    name.name_with_fossil_html fossil?
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
    string = authorship.pages.to_s
    string << " (#{authorship.forms})" if authorship.forms
    string
  end
end
