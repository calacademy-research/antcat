TAXON_NAME_STRING = AntCat.CONSTANTS.TAXON_NAME_STRING
PROTONYM_NAME_STRING = AntCat.CONSTANTS.PROTONYM_NAME_STRING
COPY_NAME_TO_PROTONYM = '#copy-name-to-protonym-js-hook'

$ ->
  $(COPY_NAME_TO_PROTONYM).click (event) ->
    event.preventDefault()
    taxon_name_string = $(TAXON_NAME_STRING).val()
    $(PROTONYM_NAME_STRING).val taxon_name_string
    $(PROTONYM_NAME_STRING).trigger('keyup')
