class Detax
  include Service

  def initialize taxt
    @taxt = taxt.try(:dup)
  end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def call
    return '' unless taxt
    Markdowns::ParseAntcatHooks[taxt, catalog_tags_only: true].html_safe
  end

  private

    attr_reader :taxt
end
