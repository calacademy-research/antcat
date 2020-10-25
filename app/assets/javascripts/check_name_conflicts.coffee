DELAY_MS = 500

TAXON_NAME_STRING = AntCat.CONSTANTS.TAXON_NAME_STRING # For the taxon form.
PROTONYM_NAME_STRING = AntCat.CONSTANTS.PROTONYM_NAME_STRING # For the taxon and protonym forms.

# For the name form.
NAME_NAME_STRING = '#name_name_string'

$ ->
  checkNameConflicts = (nameStringSelector, exceptNameId, numberOfWords) =>
    $.ajax
      url: "/names/check_name_conflicts"
      type: "get"
      data:
        qq: $(nameStringSelector).val()
        number_of_words: numberOfWords
        except_name_id: exceptNameId
      dataType: "json"
      success: (names) =>
        currentValue = $(nameStringSelector).val()
        formattedNames = names.map (name) ->
          warnAboutHomonym = name.name.toLowerCase() == $.trim(currentValue.toLowerCase())
          homonymWarning = '<span class="bold-warning">Homonym</span> '

          url = if name.taxon_id
                   "/catalog/#{name.taxon_id}"
                 else
                   "/protonyms/#{name.protonym_id}"

          string = ""
          string += homonymWarning if warnAboutHomonym
          string += "<a href='#{url}'>#{name.name_html}</a> "
          string += ' (protonym)' unless name.taxon_id
          string += " <small class='gray'>##{name.id}</small>"

          "<li>#{string}</li>"

        html = if formattedNames.length > 0
                "<h6>Similar names</h3> #{formattedNames.join('')}"
               else
                 "<h6>Found no similar names <span class='antcat_icon check'></span></h3>"

         $("#{nameStringSelector}-possible-conflicts-js-hook").html html

      error: -> AntCat.notifyError "Error checking for name conflicts"

  $(TAXON_NAME_STRING).keyup ->
    numberOfWords = $(TAXON_NAME_STRING).data('number-of-words')
    AntCat.delay(checkNameConflicts, TAXON_NAME_STRING, null, numberOfWords)

  $(PROTONYM_NAME_STRING).keyup -> AntCat.delay(checkNameConflicts, PROTONYM_NAME_STRING)

  $(NAME_NAME_STRING).keyup ->
    exceptNameId = $(NAME_NAME_STRING).data('name-id')
    AntCat.delay(checkNameConflicts, NAME_NAME_STRING, exceptNameId)

AntCat.delay = do ->
  timer = 0
  (callback, args...) ->
    clearTimeout(timer)
    cb = -> callback.apply(null, args)
    timer = setTimeout(cb, DELAY_MS)
