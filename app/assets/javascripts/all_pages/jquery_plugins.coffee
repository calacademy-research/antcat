$ ->
  jQuery.fn.extend
    # Function for inserting text at the cursor's position in a textarea.
    # From https://stackoverflow.com/questions/28873350
    insertAtCaret: (valueToInsert) ->
      return @each (i) ->
        if document.selection # For browsers like Internet Explorer.
          @focus()
          selection = document.selection.createRange()
          selection.text = valueToInsert
          @focus()
        else if @selectionStart || @selectionStart == '0' # Firefox and Webkit-based.
          startPos = @selectionStart
          endPos = @selectionEnd
          scrollTop = @scrollTop
          @value = @value.substring(0, startPos) + valueToInsert + @value.substring(endPos, @value.length)
          @focus()
          @selectionStart = startPos + valueToInsert.length
          @selectionEnd = startPos + valueToInsert.length
          @scrollTop = scrollTop
        else
          @value += valueToInsert
          @focus()
