TAXON_NAME_STRING = AntCat.CONSTANTS.TAXON_NAME_STRING
PROTONYM_NAME_STRING = AntCat.CONSTANTS.PROTONYM_NAME_STRING
COPY_NAME_TO_PROTONYM = '#copy-name-to-protonym-js-hook'

$ ->
  $(COPY_NAME_TO_PROTONYM).click (event) ->
    event.preventDefault()
    taxon_name_string = $(TAXON_NAME_STRING).get(0).value
    $(PROTONYM_NAME_STRING).get(0).value = taxon_name_string

    # To trigger the name conflict check.
    $(PROTONYM_NAME_STRING).get(0).dispatchEvent(new Event('keyup'))
