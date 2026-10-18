# frozen_string_literal: true

class Detax
  include Service
  include ActionView::Helpers::SanitizeHelper

  # Catalog tags are expanded into HTML after sanitizing, so an attribute value that holds one
  # would be turned into markup inside the attribute. The sanitizer writes attributes as
  # name="value" with quotes escaped, so a tooltip2 holding a brace can be dropped safely here.
  TOOLTIP_WITH_BRACE = /\s+tooltip2="[^"]*[{}][^"]*"/

  attr_private_initialize :taxt

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def call
    return unless taxt
    sanitized = sanitize(taxt.dup, attributes: %w[tooltip2]).to_str.gsub(TOOLTIP_WITH_BRACE, "")
    Markdowns::ParseCatalogTags[sanitized].html_safe
  end
end
