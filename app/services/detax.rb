class Detax
  include Service

  # TODO: Decide what to do with this.
  TAXT_MODELS_AND_FIELDS = [
    [Citation,         'citations',           'notes_taxt'],
    [ReferenceSection, 'reference_sections',  'references_taxt'],
    [ReferenceSection, 'reference_sections',  'subtitle_taxt'],
    [ReferenceSection, 'reference_sections',  'title_taxt'],
    [Taxon,            'taxa',                'headline_notes_taxt'],
    [Protonym,         'protonyms',           'primary_type_information_taxt'],
    [Protonym,         'protonyms',           'secondary_type_information_taxt'],
    [Protonym,         'protonyms',           'type_notes_taxt'],
    [Taxon,            'taxa',                'type_taxt'],
    [TaxonHistoryItem, 'taxon_history_items', 'taxt']
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
