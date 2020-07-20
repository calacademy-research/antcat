# frozen_string_literal: true

class Detax
  include Service
  include ActionView::Helpers::SanitizeHelper

  attr_private_initialize :taxt

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def call
    return unless taxt
    Markdowns::ParseCatalogTags[sanitize(taxt.dup).to_str].html_safe
  end
end
