class Detax
  include Service

  TAXT_MODELS_AND_FIELDS = [
    [Citation,         'notes_taxt'],
    [ReferenceSection, 'references_taxt'],
    [ReferenceSection, 'subtitle_taxt'],
    [ReferenceSection, 'title_taxt'],
    [Taxon,            'headline_notes_taxt'],
    [Protonym,         'primary_type_information_taxt'],
    [Protonym,         'secondary_type_information_taxt'],
    [Protonym,         'type_notes_taxt'],
    [Taxon,            'type_taxt'],
    [TaxonHistoryItem, 'taxt']
  ]

  def initialize taxt
    @taxt = taxt.try :dup
  end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def call
    return '' unless taxt
    Markdowns::ParseAntcatHooks[taxt].html_safe
  end

  private

    attr_reader :taxt
end
