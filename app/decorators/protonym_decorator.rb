class ProtonymDecorator < Draper::Decorator
  delegate :locality, :authorship, :name, :fossil?

  def link_to_protonym
    h.link_to format_name, h.protonym_path(protonym)
  end

  # TODO: This does not seem to be `included` when used in `DatabaseScripts::ProtonymsWithNotesTaxt`.
  def format_name
    name.name_with_fossil_html fossil?
  end

  def format_locality
    return if locality.blank?

    first_parenthesis = locality.index("(")
    capitalized =
      if first_parenthesis
        before = locality[0...first_parenthesis]
        rest = locality[first_parenthesis..-1]
        before.upcase + rest
      else
        locality.upcase
      end

    helpers.add_period_if_necessary capitalized
  end

  def format_pages_and_forms
    string = authorship.pages.to_s
    string << " (#{authorship.forms})" if authorship.forms.present?
    string
  end
end
