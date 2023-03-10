# Type-specific elements.
TYPE_SPECIFIC_SUBTYPE = '#type-specific-subtype'
TYPE_SPECIFIC_PICKED_VALUE = '#type-specific-picked-value'
TYPE_SPECIFIC_TEXT_VALUE = '#type-specific-text-value'
TYPE_SPECIFIC_REFERENCE = '#type-specific-reference'
TYPE_SPECIFIC_PAGES = '#type-specific-pages'
TYPE_SPECIFIC_OBJECT_PROTONYM = '#type-specific-object-protonym'
TYPE_SPECIFIC_OBJECT_TAXON = '#type-specific-object-taxon'
TYPE_SPECIFIC_FORCE_AUTHOR_CITATION = '#type-specific-force-author-citation'

# Type labels.
TYPE_LABEL_SUBTYPE = '#type-label-subtype'
TYPE_LABEL_PICKED_VALUE = '#type-label-picked-value'
TYPE_LABEL_TEXT_VALUE = '#type-label-text-value'
TYPE_LABEL_REFERENCE = '#type-label-reference'
TYPE_LABEL_PAGES = '#type-label-pages'
TYPE_LABEL_OBJECT_PROTONYM = '#type-label-object-protonym'
TYPE_LABEL_OBJECT_TAXON = '#type-label-object-taxon'

# Type-specific inputs.
TYPE_SELECT = '#history_item_type'
SUBTYPE_SELECT = '#history_item_subtype'
PICKED_VALUE_SELECT = '#history_item_picked_value'

# Misc.
TYPE_SPECIFIC_SECTION = '.type-specific-section' # Any type-specific section.
TYPE_SPECIFIC_HELP_PREFIX = '.type-specific-help-'

$ ->
  onSelectType($(TYPE_SELECT).get(0).value)

  $(TYPE_SELECT).change ->
    selectedType = $(this).get(0).value
    onSelectType(selectedType)

  document.body.setAttribute('data-test-taxt-editors-loaded', "true") # HACK.

setupSelect = (identifier, options) ->
  selectElement = $(identifier)
  currentValue = selectElement.get(0).value

  selectElement.empty()
  $.each options, (label, value) ->
    selectElement.append($("<option></option>").attr("value", value).text(label))
  selectElement.get(0).value = currentValue

resetTypeSpecific = ->
  $(TYPE_SPECIFIC_SECTION).hide()

  $(TYPE_LABEL_SUBTYPE).get(0).textContent = "???"
  $(TYPE_LABEL_PICKED_VALUE).get(0).textContent = "???"
  $(TYPE_LABEL_TEXT_VALUE).get(0).textContent = "???"
  $(TYPE_LABEL_OBJECT_PROTONYM).get(0).textContent = "???"
  $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "???"

  $(TYPE_LABEL_REFERENCE).get(0).textContent = "Reference"
  $(TYPE_LABEL_PAGES).get(0).textContent = "Pages"

onSelectType = (selectedType) ->
  resetTypeSpecific()

  $("#{TYPE_SPECIFIC_HELP_PREFIX}#{selectedType}").show()

  # [grep:history_type].
  inputsToShow =
    switch selectedType
      when 'Taxt'
        []

      when 'FormDescriptions'
        $(TYPE_LABEL_TEXT_VALUE).get(0).textContent = "Forms"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_TEXT_VALUE]

      when 'TypeSpecimenDesignation'
        $(TYPE_LABEL_SUBTYPE).get(0).textContent = "Designation type"

        setupSelect SUBTYPE_SELECT, {
          "(none)": ""
          "Lectotype designation": "LectotypeDesignation"
          "Neotype designation": "NeotypeDesignation"
        }

        [TYPE_SPECIFIC_SUBTYPE, TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES]

      when 'CombinationIn'
        $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "Combination in"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_TAXON]

      when 'JuniorSynonymOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).get(0).textContent = "Junior synonym of"
        [
          TYPE_SPECIFIC_REFERENCE,
          TYPE_SPECIFIC_PAGES,
          TYPE_SPECIFIC_OBJECT_PROTONYM,
          TYPE_SPECIFIC_FORCE_AUTHOR_CITATION
        ]

      when 'SeniorSynonymOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).get(0).textContent = "Senior synonym of"
        [
          TYPE_SPECIFIC_REFERENCE,
          TYPE_SPECIFIC_PAGES,
          TYPE_SPECIFIC_OBJECT_PROTONYM,
          TYPE_SPECIFIC_FORCE_AUTHOR_CITATION
        ]

      when 'SubspeciesOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).get(0).textContent = "Subspecies of"
        [
          TYPE_SPECIFIC_REFERENCE,
          TYPE_SPECIFIC_PAGES,
          TYPE_SPECIFIC_OBJECT_PROTONYM,
          TYPE_SPECIFIC_FORCE_AUTHOR_CITATION
        ]

      when 'StatusAsSpecies'
        $(TYPE_LABEL_OBJECT_PROTONYM).get(0).textContent = "Senior synonym of"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES]

      when 'JuniorPrimaryHomonymOf'
        $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "Junior primary homonym of"
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_TAXON]

      when 'JuniorPrimaryHomonymOfHardcodedGenus'
        $(TYPE_LABEL_TEXT_VALUE).get(0).textContent = "Junior primary homonym of hardcoded genus"
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_TEXT_VALUE]

      when 'JuniorSecondaryHomonymOf'
        $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "Junior secondary homonym of"
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_TAXON]

      when 'HomonymReplacedBy'
        $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "Replacement name (homonym replaced by)"
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_TAXON]

      when 'ReplacementNameFor'
        $(TYPE_LABEL_OBJECT_TAXON).get(0).textContent = "Replacement name for"
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_TAXON]

      when 'UnavailableName'
        markCitationAsOptional()

        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES]

      else
        alert "unknown type: #{selectedType}"

  for input in inputsToShow
    $(input).show()

markCitationAsOptional = ->
  $(TYPE_LABEL_REFERENCE).get(0).textContent = "Optional reference"
  $(TYPE_LABEL_PAGES).get(0).textContent = "Optional pages"
