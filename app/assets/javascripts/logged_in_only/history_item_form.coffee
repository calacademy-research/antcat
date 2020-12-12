# Type-specific elements.
TYPE_SPECIFIC_SUBTYPE = '#type-specific-subtype'
TYPE_SPECIFIC_PICKED_VALUE = '#type-specific-picked-value'
TYPE_SPECIFIC_TEXT_VALUE = '#type-specific-text-value'
TYPE_SPECIFIC_REFERENCE = '#type-specific-reference'
TYPE_SPECIFIC_PAGES = '#type-specific-pages'
TYPE_SPECIFIC_OBJECT_PROTONYM = '#type-specific-object-protonym'

# Type labels.
TYPE_LABEL_SUBTYPE = '#type-label-subtype'
TYPE_LABEL_PICKED_VALUE = '#type-label-picked-value'
TYPE_LABEL_TEXT_VALUE = '#type-label-text-value'
TYPE_LABEL_REFERENCE = '#type-label-reference'
TYPE_LABEL_PAGES = '#type-label-pages'
TYPE_LABEL_OBJECT_PROTONYM = '#type-label-object-protonym'

# Type-specific inputs.
TYPE_SELECT = '#history_item_type'
SUBTYPE_SELECT = '#history_item_subtype'
PICKED_VALUE_SELECT = '#history_item_picked_value'

# Misc.
TYPE_SPECIFIC_SECTION = '.type-specific-section' # Any type-specific section.

$ ->
  onSelectType($(TYPE_SELECT).val())

  $(TYPE_SELECT).change ->
    selectedType = $(this).val()
    onSelectType(selectedType)

onSelectType = (selectedType) ->
  $(TYPE_SPECIFIC_SECTION).hide()

  $(TYPE_LABEL_SUBTYPE).text "???"
  $(TYPE_LABEL_PICKED_VALUE).text "???"
  $(TYPE_LABEL_TEXT_VALUE).text "???"

  # [grep:history_type].
  inputsToShow =
    switch selectedType
      when 'Taxt'
        []

      when 'FormDescriptions'
        $(TYPE_LABEL_TEXT_VALUE).text "Forms"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_TEXT_VALUE]

      when 'TypeSpecimenDesignation'
        $(TYPE_LABEL_SUBTYPE).text "Designation type"

        subtypeSelect = $(SUBTYPE_SELECT)
        currentValue = subtypeSelect.val()
        subtypeOptions = {
          "(none)": "",
          "Lectotype designation": "LectotypeDesignation",
          "Neotype designation": "NeotypeDesignation"
        }

        subtypeSelect.empty()
        $.each subtypeOptions, (label, value) ->
          subtypeSelect.append($("<option></option>").attr("value", value).text(label))
        subtypeSelect.val(currentValue)

        [TYPE_SPECIFIC_SUBTYPE, TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES]

      when 'CombinationIn'
        $(TYPE_LABEL_OBJECT_PROTONYM).text "Combination in"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_PROTONYM]

      when 'JuniorSynonymOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).text "Junior synonym of"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_PROTONYM]

      when 'SeniorSynonymOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).text "Senior synonym of"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_PROTONYM]

      when 'SubspeciesOf'
        $(TYPE_LABEL_OBJECT_PROTONYM).text "Subspecies of"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES, TYPE_SPECIFIC_OBJECT_PROTONYM]

      when 'StatusAsSpecies'
        $(TYPE_LABEL_OBJECT_PROTONYM).text "Senior synonym of"
        [TYPE_SPECIFIC_REFERENCE, TYPE_SPECIFIC_PAGES]

      else
        alert "unknown type: #{selectedType}"

  for input in inputsToShow
    $(input).show()
