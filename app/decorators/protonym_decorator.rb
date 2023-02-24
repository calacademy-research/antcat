# frozen_string_literal: true

class ProtonymDecorator < Draper::Decorator
  delegate :locality, :forms, :authorship

  def link_to_protonym
    link_to_protonym_with_label protonym.name_with_fossil
  end

  def link_to_protonym_with_author_citation
    link_to_protonym << ' ' << protonym.author_citation.html_safe
  end

  def link_to_protonym_epithet
    link_to_protonym_with_label(protonym.name.epithet_html)
  end

  # TODO: Probably move to `CatalogFormatter`.
  def link_to_protonym_with_linked_author_citation
    authorship_reference = protonym.authorship_reference

    link_to_protonym <<
      ' ' <<
      h.tag.span(
        h.link_to(
          protonym.author_citation.html_safe,
          h.reference_path(authorship_reference),
          "data-controller" => "hover-preview",
          "data-hover-preview-url-value" => "/references/#{authorship_reference.id}/hover_preview.json"
        ),
        class: 'discreet-author-citation'
      )
  end

  def format_locality
    return unless locality

    # Only capitalize up until the first parenthesis.
    if (first_parenthesis = locality.index("("))
      before = locality[0...first_parenthesis]
      rest = locality[first_parenthesis..]
      before.mb_chars.upcase + rest
    else
      locality.mb_chars.upcase
    end
  end

  def format_pages_and_forms
    string = authorship.pages.dup
    string << " (#{forms})" if forms
    string
  end

  private

    def link_to_protonym_with_label label
      h.link_to label, h.protonym_path(protonym),
        "data-controller" => "hover-preview",
        "data-hover-preview-url-value" => "/protonyms/#{protonym.id}/hover_preview.json",
        class: 'protonym'
    end
end
